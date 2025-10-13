//
//  CheckNet.swift
//  WatchJM Watch App
//
//  Created by Maverick Charmer on 2025/10/13.
//

import Foundation

//example:{"status":"ok","app":"jmcomic_server_api","latency":"644","version": "1.0"}
//V1.0
struct CheckNet:Codable {
	var status: String
	var app: String
	var latency: String
	var version: String
}
