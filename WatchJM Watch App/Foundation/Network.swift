//
//  Network.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/17.
//

import Foundation
import SwiftyJSON

class Net {
    static let shared = Net()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }

    // MARK: - URL Helpers

    /// Strips trailing slashes from the base URL.
    private func normalizeURL(_ jmurl: String) -> String {
        var url = jmurl.trimmingCharacters(in: .whitespacesAndNewlines)
        while url.hasSuffix("/") {
            url = String(url.dropLast())
        }
        return url
    }

    /// Extracts the host from jmurl for WebSocket connections (strips /v1 prefix).
    private func wsHost(from jmurl: String) -> String? {
        let normalized = normalizeURL(jmurl)
        guard let components = URLComponents(string: normalized) else { return nil }
        return components.host
    }

    // MARK: - Health Check

    func checkLatency(jmurl: String) async throws -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince1970 * 1000
        guard let url = URL(string: "\(normalizeURL(jmurl))/\(String(timeInterval))") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSON(data: data)
        if json["status"] == "ok", json["app"] == "jmcomic_server_api" {
            return json["latency"].stringValue
        }
        throw URLError(.cannotParseResponse)
    }

    // MARK: - Rankings

    func getRank(time: String = "month", jmurl: String) async throws -> [Album] {
        guard let url = URL(string: "\(normalizeURL(jmurl))/rank/\(time)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSON(data: data)
        var tempList: [Album] = []
        for dic in json {
            let title = dic.1["title"].stringValue
            let aid = dic.1["aid"].stringValue
            guard !title.isEmpty, !aid.isEmpty else { continue }
            tempList.append(Album(title: title, aid: aid))
        }
        return tempList
    }

    // MARK: - Search

    func searchAlbum(jmurl: String, content: String, page: Int = 1) async throws -> [Album] {
        let encoded = content.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? content
        guard let url = URL(string: "\(normalizeURL(jmurl))/search/\(encoded)/\(page)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSON(data: data)
        var tempList: [Album] = []
        for dic in json {
            let title = dic.1["title"].stringValue
            let albumId = dic.1["album_id"].stringValue
            guard !title.isEmpty, !albumId.isEmpty else { continue }
            tempList.append(Album(title: title, aid: albumId))
        }
        return tempList
    }

    // MARK: - Album Info

    func getInfo(jmurl: String, album: Album) async throws -> Album {
        var updatedAlbum = album
        guard let url = URL(string: "\(normalizeURL(jmurl))/info/\(album.aid)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSON(data: data)

        // page_count is a string from the API
        updatedAlbum.page_count = Int(json["page_count"].stringValue) ?? 0

        // like_count and view_count are integers from the API
        updatedAlbum.likes = json["like_count"].intValue
        updatedAlbum.views = json["view_count"].intValue

        // method: "html" or "api"
        updatedAlbum.method = json["method"].string

        // tags: the key is "tag" (singular) in the API response
        var tempTags: [String] = []
        for tag in json["tag"].arrayValue {
            tempTags.append(tag.stringValue)
        }
        updatedAlbum.tags = tempTags

        return updatedAlbum
    }

    // MARK: - Download Orchestration (WebSocket Flow)

    /// Full download flow: WebSocket → POST → wait for notification → GET zip → unzip.
    func downloadViaWebSocket(
        jmurl: String,
        album: Album,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> URL {
        let clientId = UUID().uuidString
        let normalized = normalizeURL(jmurl)

        // 1. Build WebSocket URL
        guard let host = wsHost(from: jmurl) else {
            throw URLError(.badURL)
        }
        let wsURLString = "wss://\(host)/ws/notifications/\(clientId)"
        guard let wsURL = URL(string: wsURLString) else {
            throw URLError(.badURL)
        }

        // 2. Connect WebSocket
        let wsTask = session.webSocketTask(with: wsURL)
        wsTask.resume()

        // 3. POST download request
        let postURLString = "\(normalized)/download/album/\(album.aid)"
        guard let postURL = URL(string: postURLString) else {
            wsTask.cancel(with: .abnormalClosure, reason: nil)
            throw URLError(.badURL)
        }
        var request = URLRequest(url: postURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["client_id": clientId]
        request.httpBody = try JSONEncoder().encode(body)

        let (_, postResponse) = try await session.data(for: request)
        guard let httpResponse = postResponse as? HTTPURLResponse, httpResponse.statusCode == 202 else {
            wsTask.cancel(with: .abnormalClosure, reason: nil)
            throw URLError(.badServerResponse)
        }

        // 4. Wait for WebSocket notification
        let message = try await wsTask.receive()
        wsTask.cancel(with: .normalClosure, reason: nil)

        var fileName: String?
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               status == "download_ready",
               let name = json["file_name"] as? String {
                fileName = name
            }
        case .data(let data):
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               status == "download_ready",
               let name = json["file_name"] as? String {
                fileName = name
            }
        @unknown default:
            break
        }

        guard let fileName = fileName else {
            throw URLError(.cannotParseResponse)
        }

        // 5. Download the zip file
        let downloadURLString = "\(normalized)/download/\(fileName)"
        guard let downloadURL = URL(string: downloadURLString) else {
            throw URLError(.badURL)
        }
        return try await downloadAlbum(
            fileUrl: downloadURL,
            album: album,
            progressHandler: progressHandler
        )
    }

    // MARK: - File Download (chunked)

    func downloadAlbum(
        fileUrl: URL,
        album: Album,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> URL {
        let file = File()
        let (asyncBytes, response) = try await session.bytes(from: fileUrl)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let totalBytes = httpResponse.expectedContentLength
        let tempDestinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).zip")

        // Create file for writing
        FileManager.default.createFile(atPath: tempDestinationURL.path, contents: nil, attributes: nil)
        let fileHandle = try FileHandle(forWritingTo: tempDestinationURL)
        defer { try? fileHandle.close() }

        var downloadedBytes: Int64 = 0
        let chunkSize = 64 * 1024       // 64 KB write buffer
        let progressInterval: Int64 = 256 * 1024  // update progress every 256 KB
        var buffer = Data(capacity: chunkSize)
        var lastProgressUpdate: Int64 = 0

        for try await byte in asyncBytes {
            buffer.append(byte)
            downloadedBytes += 1

            if buffer.count >= chunkSize || downloadedBytes >= totalBytes {
                try fileHandle.write(contentsOf: buffer)
                buffer.removeAll(keepingCapacity: true)
            }

            if totalBytes > 0,
               (downloadedBytes - lastProgressUpdate >= progressInterval
                || downloadedBytes >= totalBytes) {
                let progress = Float(Double(downloadedBytes) / Double(totalBytes))
                DispatchQueue.main.async {
                    progressHandler(progress)
                }
                lastProgressUpdate = downloadedBytes
            }
        }

        // Flush any remaining bytes
        if !buffer.isEmpty {
            try fileHandle.write(contentsOf: buffer)
        }

        try fileHandle.close()
        return try file.unzip(tempDestinationURL, album: album)
    }
}
