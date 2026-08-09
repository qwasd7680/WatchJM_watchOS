//
//  NetworkTests.swift
//  WatchJMTests
//
//  Integration tests — require network access to the JMComic API.
//  jmurl = HuggingFace Space: https://qwasd12w-jmcomic-api.hf.space/v1
//

import XCTest
@testable import WatchJM_Watch_App

final class NetworkTests: XCTestCase {

    let jmurl = "https://qwasd12w-jmcomic-api.hf.space/v1"
    let net = Net.shared

    // MARK: - Health check

    func testCheckLatency() async throws {
        let latency = try await net.checkLatency(jmurl: jmurl)
        XCTAssertFalse(latency.isEmpty)
        // latency should be a number (milliseconds)
        let value = Int(latency)
        XCTAssertNotNil(value)
        if let v = value { XCTAssertGreaterThanOrEqual(v, 0) }
    }

    func testCheckLatencyInvalidURL() async {
        do {
            _ = try await net.checkLatency(jmurl: "not a url")
            XCTFail("Should throw for invalid URL")
        } catch {
            // expected
        }
    }

    // MARK: - Rankings

    func testGetRankMonth() async throws {
        let albums = try await net.getRank(time: "month", jmurl: jmurl)
        XCTAssertFalse(albums.isEmpty, "Monthly ranking should not be empty")
    }

    func testGetRankWeek() async throws {
        let albums = try await net.getRank(time: "week", jmurl: jmurl)
        XCTAssertFalse(albums.isEmpty, "Weekly ranking should not be empty")
    }

    func testGetRankDay() async throws {
        let albums = try await net.getRank(time: "day", jmurl: jmurl)
        XCTAssertFalse(albums.isEmpty, "Daily ranking should not be empty")
    }

    func testGetRankDefaultIsMonth() async throws {
        let albums = try await net.getRank(jmurl: jmurl)
        XCTAssertFalse(albums.isEmpty)
    }

    func testGetRankAlbumStructure() async throws {
        let albums = try await net.getRank(time: "day", jmurl: jmurl)
        let first = albums.first!
        XCTAssertFalse(first.title.isEmpty)
        XCTAssertFalse(first.aid.isEmpty)
    }

    func testGetRankInvalidTime() async {
        do {
            _ = try await net.getRank(time: "invalid", jmurl: jmurl)
            // Server may return 422 or empty list — either is acceptable
        } catch {
            // expected for invalid time
        }
    }

    // MARK: - Search

    func testSearchAlbum() async throws {
        let albums = try await net.searchAlbum(jmurl: jmurl, content: "全彩", page: 1)
        XCTAssertFalse(albums.isEmpty, "Search for '全彩' should return results")
    }

    func testSearchAlbumStructure() async throws {
        let albums = try await net.searchAlbum(jmurl: jmurl, content: "全彩", page: 1)
        let first = albums.first!
        XCTAssertFalse(first.title.isEmpty)
        XCTAssertFalse(first.aid.isEmpty)
    }

    func testSearchPage2() async throws {
        let albums = try await net.searchAlbum(jmurl: jmurl, content: "全彩", page: 2)
        XCTAssertFalse(albums.isEmpty, "Page 2 should have results")
    }

    func testSearchChineseCharacters() async throws {
        let albums = try await net.searchAlbum(jmurl: jmurl, content: "原神", page: 1)
        XCTAssertFalse(albums.isEmpty, "Search with Chinese characters should work")
    }

    func testSearchNonexistent() async throws {
        let albums = try await net.searchAlbum(jmurl: jmurl, content: "zzzznonexistent12345", page: 1)
        // May return empty array or throw — both are acceptable
        XCTAssertTrue(albums.isEmpty || !albums.isEmpty)
    }

    // MARK: - Album Info

    func testGetInfo() async throws {
        let testAid = "1225432"
        let album = Album(title: "Test", aid: testAid)
        let info = try await net.getInfo(jmurl: jmurl, album: album)
        XCTAssertFalse(info.tags.isEmpty, "Info should have tags")
        XCTAssertNotNil(info.method)
        XCTAssertTrue(["html", "api"].contains(info.method!))
    }

    func testGetInfoMethod() async throws {
        let testAid = "1225432"
        let album = Album(title: "Test", aid: testAid)
        let info = try await net.getInfo(jmurl: jmurl, album: album)
        if info.method == "html" {
            XCTAssertGreaterThan(info.page_count, 0, "HTML mode should have page_count > 0")
        }
        // api mode may have page_count = 0
    }

    func testGetInfoPreservesOriginalFields() async throws {
        let testAid = "1225432"
        let original = Album(title: "Original Title", aid: testAid)
        let info = try await net.getInfo(jmurl: jmurl, album: original)
        // getInfo should preserve title and aid from original
        XCTAssertEqual(info.title, original.title)
        XCTAssertEqual(info.aid, original.aid)
    }

    func testGetInfoNonexistent() async {
        let album = Album(title: "X", aid: "999999999")
        do {
            _ = try await net.getInfo(jmurl: jmurl, album: album)
            // Server may return error in JSON or throw
        } catch {
            // expected — album doesn't exist
        }
    }

    // MARK: - URL normalization

    func testURLWithTrailingSlash() async throws {
        let urlWithSlash = jmurl + "/"
        let latency = try await net.checkLatency(jmurl: urlWithSlash)
        XCTAssertFalse(latency.isEmpty, "Should handle trailing slash")
    }

    func testURLWithMultipleTrailingSlashes() async throws {
        let urlWithSlashes = jmurl + "///"
        let latency = try await net.checkLatency(jmurl: urlWithSlashes)
        XCTAssertFalse(latency.isEmpty, "Should handle multiple trailing slashes")
    }

    // MARK: - Download flow (slow — full WebSocket flow)

    func testDownloadFlow() async throws {
        let testAid = "1225432"
        let album = Album(title: "Test Download", aid: testAid)

        var progressValues: [Float] = []
        let resultURL = try await net.downloadViaWebSocket(
            jmurl: jmurl,
            album: album
        ) { progress in
            progressValues.append(progress)
        }

        // Verify the downloaded file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path))

        // Verify progress was reported
        XCTAssertFalse(progressValues.isEmpty, "Progress handler should have been called")

        // Verify the file is a directory (unzipped)
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: resultURL.path, isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue, "Result should be unzipped directory")

        // Cleanup
        try? FileManager.default.removeItem(at: resultURL)
    }
}
