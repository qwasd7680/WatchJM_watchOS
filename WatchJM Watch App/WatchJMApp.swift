//
//  WatchJMApp.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import SDWebImageWebPCoder
import SDWebImageSwiftUI


@main
struct WatchJM_Watch_AppApp: App {
    init() {
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        SDWebImageDownloader.shared.config.downloadTimeout = 60
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
