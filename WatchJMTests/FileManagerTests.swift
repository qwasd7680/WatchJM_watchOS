//
//  FileManagerTests.swift
//  WatchJMTests
//
//  Tests for File struct — local storage, JSON round-trip, directory operations.
//

import XCTest
@testable import WatchJM_Watch_App

final class FileManagerTests: XCTestCase {

    let file = File()

    // MARK: - isExist

    func testIsExistNonexistent() throws {
        let result = try file.isExist(aid: "nonexistent_aid_999")
        XCTAssertNil(result, "Non-existent album should return nil")
    }

    // MARK: - DownloadedAlbumFinder

    func testDownloadedAlbumFinderReturnsURL() {
        let url = file.DownloadedAlbumFinder(aid: "12345")
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.path.contains("DownloadedAlbum"))
        XCTAssertTrue(url!.path.contains("12345"))
    }

    func testDownloadedAlbumFinderDifferentAids() {
        let url1 = file.DownloadedAlbumFinder(aid: "111")
        let url2 = file.DownloadedAlbumFinder(aid: "222")
        XCTAssertNotEqual(url1, url2)
    }

    // MARK: - Album2JSON / JSON2Album round-trip

    func testAlbum2JSONAndBack() {
        let testAid = "test_roundtrip_\(UUID().uuidString.prefix(8))"
        let album = Album(
            title: "Test Album",
            aid: testAid,
            tags: ["tag1", "tag2"],
            page_count: 42,
            likes: 7,
            views: 100,
            method: "api"
        )

        // Save to JSON
        file.Album2JSON(album: album)

        // Read back
        let loaded = file.JSON2Album(aid: testAid)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded!.title, album.title)
        XCTAssertEqual(loaded!.aid, album.aid)
        XCTAssertEqual(loaded!.tags, album.tags)
        XCTAssertEqual(loaded!.page_count, album.page_count)
        XCTAssertEqual(loaded!.likes, album.likes)
        XCTAssertEqual(loaded!.views, album.views)
        XCTAssertEqual(loaded!.method, album.method)

        // Cleanup
        cleanupAlbum(testAid)
    }

    func testAlbum2JSONWithEmptyTags() {
        let testAid = "test_empty_tags_\(UUID().uuidString.prefix(8))"
        let album = Album(title: "Empty Tags", aid: testAid, tags: [])

        file.Album2JSON(album: album)
        let loaded = file.JSON2Album(aid: testAid)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded!.tags, [])

        cleanupAlbum(testAid)
    }

    func testAlbum2JSONWithUnicodeTitle() {
        let testAid = "test_unicode_\(UUID().uuidString.prefix(8))"
        let title = "［酸菜鱼ゅ°］ヒルチャールに败北した胡桃"
        let album = Album(title: title, aid: testAid)

        file.Album2JSON(album: album)
        let loaded = file.JSON2Album(aid: testAid)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded!.title, title)

        cleanupAlbum(testAid)
    }

    func testJSON2AlbumNonexistent() {
        let result = file.JSON2Album(aid: "nonexistent_999")
        XCTAssertNil(result, "Non-existent album JSON should return nil")
    }

    func testAlbum2JSONOverwrites() {
        let testAid = "test_overwrite_\(UUID().uuidString.prefix(8))"

        let album1 = Album(title: "Version 1", aid: testAid, views: 10)
        file.Album2JSON(album: album1)

        let album2 = Album(title: "Version 2", aid: testAid, views: 20)
        file.Album2JSON(album: album2)

        let loaded = file.JSON2Album(aid: testAid)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded!.title, "Version 2")
        XCTAssertEqual(loaded!.views, 20)

        cleanupAlbum(testAid)
    }

    // MARK: - getSubdirectories

    func testGetSubdirectoriesCreatesDirIfMissing() {
        // This tests that getSubdirectories creates DownloadedAlbum/ if it doesn't exist
        // (it might already exist from other tests)
        let result = file.getSubdirectories()
        XCTAssertNotNil(result, "Should return array (possibly empty)")
    }

    func testGetSubdirectoriesAfterCreatingAlbum() {
        let testAid = "test_subdir_\(UUID().uuidString.prefix(8))"
        let album = Album(title: "Subdir Test", aid: testAid)

        file.Album2JSON(album: album)

        let subdirs = file.getSubdirectories()
        XCTAssertNotNil(subdirs)
        XCTAssertTrue(subdirs!.contains(testAid), "Should contain the newly created album ID")

        cleanupAlbum(testAid)
    }

    // MARK: - coverFinder

    func testCoverFinderNonexistent() {
        XCTAssertThrowsError(try file.coverFinder(aid: "nonexistent_999")) { error in
            XCTAssertTrue(error is URLError)
        }
    }

    // MARK: - Helpers

    private func cleanupAlbum(_ aid: String) {
        let fm = FileManager.default
        guard let docs = try? fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let albumDir = docs.appendingPathComponent("DownloadedAlbum").appendingPathComponent(aid)
        try? fm.removeItem(at: albumDir)
    }
}
