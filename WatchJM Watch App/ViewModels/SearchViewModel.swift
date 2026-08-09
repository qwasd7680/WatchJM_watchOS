//
//  SearchViewModel.swift
//  WatchJM
//

import SwiftUI

@Observable
final class SearchViewModel {
    var results: [Album] = []
    var isLoading = false
    var errorMessage: String? = nil
    var searchQuery = ""
    var currentPage = 1
    var hasSearched = false

    func search(jmurl: String) async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1
        do {
            results = try await Net.shared.searchAlbum(
                jmurl: jmurl,
                content: searchQuery,
                page: currentPage
            )
            hasSearched = true
        } catch {
            errorMessage = "搜索失败: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func loadMore(jmurl: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage += 1
        do {
            let more = try await Net.shared.searchAlbum(
                jmurl: jmurl,
                content: searchQuery,
                page: currentPage
            )
            results.append(contentsOf: more)
        } catch {
            currentPage -= 1
            errorMessage = "加载更多失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
