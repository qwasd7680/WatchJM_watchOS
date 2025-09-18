//
//  Network.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/17.
//

import Foundation
import SwiftyJSON

class Net{
    func Check(jmurl:String,timeInterval:Double) async throws -> String {
        var latency = ""
        guard let url = URL(string: jmurl+"/"+String(timeInterval)) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try! JSON(data: data)
        if json["status"] == "ok" && json["app"] == "jmcomic_server_api"{
            latency = json["latency"].string!
        }
        return latency
    }
    func GetRank(time:String = "month",jmurl:String) async throws -> [Album] {
        var tempList:[Album] = []
        guard let url = URL(string: jmurl+"/rank/"+time) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try! JSON(data: data)
        for dic in json {
            tempList.append(Album(id: UUID(), title: dic.1["title"].string!, aid: dic.1["aid"].string!))
        }
        return tempList
    }
    func getInfo(jmurl:String,album:Album) async throws -> Album{
        var album1 = album
        var tempTags:[String] = []
        guard let url = URL(string: jmurl+"/info/"+album.aid) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try! JSON(data: data)
        album1.cover = json["id"].string!
        for tag in json["tag"].array!{
            tempTags.append(tag.string!)
        }
        album1.tags = tempTags
        return album1
    }
    func startdownload(jmurl: String, album: Album) async throws -> (URL?,Bool) {
        let fileUrlString = jmurl + "/download/album/" + album.aid
        guard let url = URL(string: fileUrlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try! JSON(data: data)
        guard json["status"].string! == "success" else {
            throw URLError(.fileDoesNotExist)
        }
        let file_name = json["file_name"].string!
        return (URL(string: jmurl + "/download/" + file_name),true)
    }
    func downloadAlbum(fileUrl: URL, album: Album, progressHandler: @escaping (Float) -> Void) async throws -> URL {
        let url = URL(string: fileUrl.absoluteString)!
        let file = File()
        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let totalBytes = httpResponse.expectedContentLength
        var downloadedBytes: Int64 = 0
        let tempDestinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).zip")
        var downloadedData = Data()
        let updateInterval: Int64 = 512 * 1024
        var lastUpdateBytes: Int64 = 0
        for try await byte in asyncBytes {
            downloadedData.append(byte)
            downloadedBytes += 1
            if downloadedBytes - lastUpdateBytes > updateInterval || downloadedBytes == totalBytes {
                let progress = Float(Double(downloadedBytes) / Double(totalBytes))
                DispatchQueue.main.async {
                    progressHandler(progress)
                }
                lastUpdateBytes = downloadedBytes
            }
        }
        try downloadedData.write(to: tempDestinationURL, options: .atomic)
        return try file.unzip(tempDestinationURL, album: album)
    }
}
