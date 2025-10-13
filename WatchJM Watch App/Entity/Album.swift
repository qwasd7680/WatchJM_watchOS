//
//  Album.swift
//  WatchJM
//
//  Created by Maverick Charmer on 2025/8/17.
//

import Foundation

struct Album: Identifiable, Codable, Hashable {
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

func mixInfo(Info:AlbumInfo,album:Album) -> Album {
	var temp = album
	temp.tags = Info.tag
	temp.views = Info.view_count
	temp.likes = Info.like_count
	temp.page_count = Info.page_count
	temp.method = Info.method
	
	return temp
}

//example:{"status":"success","tag":["全彩","巨乳","强姦","强暴","CG集","AI绘图","中文"],"view_count":"102497","like_count":"42","page_count":"20","method": "html"}
//V1.0
struct AlbumInfo: Codable {
	var status: String
	var tag: [String]
	var view_count: String
	var like_count: String
	var page_count: String
	var method: String
}
