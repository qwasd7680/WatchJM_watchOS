//
//  WatchJMApp.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import SDWebImageWebPCoder


@main
struct WatchJM_Watch_AppApp: App {
    init() {
            let WebPCoder = SDImageWebPCoder.shared
            SDImageCodersManager.shared.addCoder(WebPCoder)
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
