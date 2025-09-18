//
//  Album.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/17.
//

import Foundation

struct Album: Identifiable, Codable,Hashable{
    let id: UUID
    let title: String
    let aid: String
    var cover: String = ""
    var tags:[String] = [""]
    var url:URL? = nil
}
