//
//  DownloadTaskPayload.swift
//  WatchJM
//
//  Created by Maverick Charmer on 2025/9/30.
//

import Foundation

// --- 异步下载任务所需模型 ---

struct DownloadTaskInitiationResponse: Codable {
    let status: String // Expected: "processing"
    let message: String
}
