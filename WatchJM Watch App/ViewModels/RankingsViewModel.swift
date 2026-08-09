//
//  RankingsViewModel.swift
//  WatchJM
//

import SwiftUI

@Observable
final class RankingsViewModel {
    var rankList: [Album] = []
    var isLoading = false
    var errorMessage: String? = nil

    func loadRankings(jmurl: String) async {
        isLoading = true
        errorMessage = nil
        do {
            rankList = try await Net.shared.getRank(jmurl: jmurl)
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
