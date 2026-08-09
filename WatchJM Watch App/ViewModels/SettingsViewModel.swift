//
//  SettingsViewModel.swift
//  WatchJM
//

import SwiftUI

@Observable
final class SettingsViewModel {
    var latencyText = "检查中..."
    var isChecking = false

    func checkLatency(jmurl: String) async {
        isChecking = true
        latencyText = "检查中..."
        do {
            let latency = try await Net.shared.checkLatency(jmurl: jmurl)
            latencyText = "\(latency)ms"
        } catch {
            latencyText = "无法连接"
        }
        isChecking = false
    }
}
