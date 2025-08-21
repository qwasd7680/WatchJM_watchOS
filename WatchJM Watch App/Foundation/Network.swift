//
//  Network.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/17.
//

import Foundation
import SwiftyJSON

struct Net{
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
}
