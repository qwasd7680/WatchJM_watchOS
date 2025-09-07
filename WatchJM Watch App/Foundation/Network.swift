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
        guard let url = URL(string: jmurl+"/"+String(Int(timeInterval))) else {
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
            tempList.append(Album(title: dic.1["title"].string!, aid: dic.1["aid"].string!))
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
            guard #available(iOS 15.0, macOS 12.0, *), let url = URL(string: fileUrl.absoluteString) else {
                throw URLError(.unsupportedURL)
            }
            
            let file = File()
            
            let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let totalBytes = httpResponse.expectedContentLength
            var downloadedBytes: Int64 = 0
            let tempDestinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).zip")
            FileManager.default.createFile(atPath: tempDestinationURL.path, contents: nil, attributes: nil)
            
            let fileHandle = try FileHandle(forWritingTo: tempDestinationURL)
            
            for try await byte in asyncBytes {
                try fileHandle.write(contentsOf: [byte])
                downloadedBytes += 1
                
                if totalBytes > 0 {
                    let progress = Float(Double(downloadedBytes) / Double(totalBytes))
                    DispatchQueue.main.async {
                        progressHandler(progress)
                    }
                }
            }
            
            try fileHandle.close()
        return try file.unzip(zipFileURL: tempDestinationURL, album: album)
        }
}
