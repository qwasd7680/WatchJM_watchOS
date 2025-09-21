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
	var page_count = "0"
	var likes = "0"
	var views = "0"
	var method: String? = nil
}
