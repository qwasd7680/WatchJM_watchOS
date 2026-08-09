//
//  AlbumTests.swift
//  WatchJMTests
//
//  Unit tests for the Album model — Codable, defaults, edge cases.
//

import XCTest
@testable import WatchJM_Watch_App

final class AlbumTests: XCTestCase {

    // MARK: - Init defaults

    func testDefaultInit() {
        let album = Album(title: "Test", aid: "123")
        XCTAssertEqual(album.title, "Test")
        XCTAssertEqual(album.aid, "123")
        XCTAssertEqual(album.cover, "")
        XCTAssertEqual(album.tags, [])
        XCTAssertNil(album.url)
        XCTAssertEqual(album.page_count, 0)
        XCTAssertEqual(album.likes, 0)
        XCTAssertEqual(album.views, 0)
        XCTAssertNil(album.method)
    }

    func testFullInit() {
        let url = URL(string: "https://example.com")!
        let album = Album(
            title: "T", aid: "1",
            cover: "c", tags: ["a", "b"],
            url: url, page_count: 10,
            likes: 5, views: 100,
            method: "html"
        )
        XCTAssertEqual(album.cover, "c")
        XCTAssertEqual(album.tags, ["a", "b"])
        XCTAssertEqual(album.url, url)
        XCTAssertEqual(album.page_count, 10)
        XCTAssertEqual(album.method, "html")
    }

    // MARK: - Identifiable & Hashable

    func testIdentifiable() {
        let a = Album(title: "T", aid: "1")
        let b = Album(title: "T", aid: "1")
        XCTAssertNotEqual(a.id, b.id) // UUIDs differ
    }

    func testHashable() {
        let a = Album(title: "T", aid: "1")
        let set: Set<Album> = [a]
        XCTAssertTrue(set.contains(a))
    }

    // MARK: - Codable: round-trip

    func testCodableRoundTrip() throws {
        let original = Album(
            title: "テスト", aid: "999",
            cover: "cover.jpg", tags: ["tag1", "tag2"],
            page_count: 42, likes: 7, views: 500,
            method: "api"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Album.self, from: data)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.aid, original.aid)
        XCTAssertEqual(decoded.cover, original.cover)
        XCTAssertEqual(decoded.tags, original.tags)
        XCTAssertEqual(decoded.page_count, original.page_count)
        XCTAssertEqual(decoded.likes, original.likes)
        XCTAssertEqual(decoded.views, original.views)
        XCTAssertEqual(decoded.method, original.method)
    }

    // MARK: - Codable: decodeIntOrString

    func testDecodeIntFieldsAsStrings() throws {
        let json = """
        {
            "title": "Test",
            "aid": "123",
            "page_count": "30",
            "likes": "42",
            "views": "999"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.page_count, 30)
        XCTAssertEqual(album.likes, 42)
        XCTAssertEqual(album.views, 999)
    }

    func testDecodeIntFieldsAsInts() throws {
        let json = """
        {
            "title": "Test",
            "aid": "123",
            "page_count": 30,
            "likes": 42,
            "views": 999
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.page_count, 30)
        XCTAssertEqual(album.likes, 42)
        XCTAssertEqual(album.views, 999)
    }

    func testDecodeIntFieldsMissing() throws {
        let json = """
        {
            "title": "Test",
            "aid": "123"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.page_count, 0)
        XCTAssertEqual(album.likes, 0)
        XCTAssertEqual(album.views, 0)
    }

    func testDecodeIntFieldsInvalidString() throws {
        let json = """
        {
            "title": "Test",
            "aid": "123",
            "page_count": "not_a_number",
            "likes": "",
            "views": "abc"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.page_count, 0)
        XCTAssertEqual(album.likes, 0)
        XCTAssertEqual(album.views, 0)
    }

    // MARK: - Codable: optional fields

    func testDecodeMissingOptionals() throws {
        let json = """
        {
            "title": "T",
            "aid": "1"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.cover, "")
        XCTAssertEqual(album.tags, [])
        XCTAssertNil(album.url)
        XCTAssertNil(album.method)
    }

    func testDecodeWithTags() throws {
        let json = """
        {
            "title": "T",
            "aid": "1",
            "tags": ["全彩", "CG集", "中文"]
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.tags, ["全彩", "CG集", "中文"])
    }

    func testDecodeIdMissingGeneratesUUID() throws {
        let json = """
        {
            "title": "T",
            "aid": "1"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertNotNil(album.id) // auto-generated
    }

    func testDecodeIdPresent() throws {
        let uuid = UUID().uuidString
        let json = """
        {
            "id": "\(uuid)",
            "title": "T",
            "aid": "1"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.id.uuidString, uuid)
    }

    // MARK: - Codable: API response format

    func testDecodeAPIInfoResponse() throws {
        // Simulates the response from /v1/info/{aid}
        let json = """
        {
            "status": "success",
            "tag": ["全彩", "巨乳", "中文"],
            "view_count": 102497,
            "like_count": 42,
            "page_count": "20",
            "method": "html"
        }
        """.data(using: .utf8)!

        // The API response doesn't have "title" or "aid" — decoding should fail
        // because those are required fields in Album
        let result = try? JSONDecoder().decode(Album.self, from: json)
        XCTAssertNil(result, "API info response missing title/aid should fail to decode")
    }

    func testDecodeSearchResultItem() throws {
        // Simulates an item from /v1/search/{tag}/{num}
        let json = """
        {
            "album_id": "1208626",
            "title": "[禁漫汉化组] テスト"
        }
        """.data(using: .utf8)!

        // search uses "album_id" not "aid" — so Album won't decode this directly
        // (Network.swift constructs Album manually from search results)
        let result = try? JSONDecoder().decode(Album.self, from: json)
        XCTAssertNil(result, "Search result uses album_id, not aid — manual construction needed")
    }

    func testDecodeRankResultItem() throws {
        // Simulates an item from /v1/rank/{time}
        let json = """
        {
            "aid": "1208626",
            "title": "[禁漫汉化组] テスト"
        }
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.aid, "1208626")
        XCTAssertEqual(album.title, "[禁漫汉化組] テスト")
    }

    // MARK: - Codable: encode

    func testEncodeProducesValidJSON() throws {
        let album = Album(title: "T", aid: "1", tags: ["a"])
        let data = try JSONEncoder().encode(album)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["title"] as? String, "T")
        XCTAssertEqual(json?["aid"] as? String, "1")
    }

    func testEncodeDecodeRoundTripPreservesTags() throws {
        let album = Album(title: "T", aid: "1", tags: ["全彩", ""])
        let data = try JSONEncoder().encode(album)
        let decoded = try JSONDecoder().decode(Album.self, from: data)
        XCTAssertEqual(decoded.tags, ["全彩", ""])
    }

    // MARK: - Edge cases

    func testEmptyTitle() throws {
        let album = Album(title: "", aid: "1")
        XCTAssertEqual(album.title, "")
        let data = try JSONEncoder().encode(album)
        let decoded = try JSONDecoder().decode(Album.self, from: data)
        XCTAssertEqual(decoded.title, "")
    }

    func testUnicodeTitle() throws {
        let title = "［酸菜鱼ゅ°］ヒルチャールに败北した胡桃"
        let album = Album(title: title, aid: "1225432")
        XCTAssertEqual(album.title, title)
        let data = try JSONEncoder().encode(album)
        let decoded = try JSONDecoder().decode(Album.self, from: data)
        XCTAssertEqual(decoded.title, title)
    }

    func testLargePageCount() throws {
        let json = """
        {"title": "T", "aid": "1", "page_count": "99999"}
        """.data(using: .utf8)!
        let album = try JSONDecoder().decode(Album.self, from: json)
        XCTAssertEqual(album.page_count, 99999)
    }
}
