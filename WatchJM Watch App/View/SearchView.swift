//
//  SearchView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/9/10.
//

import SwiftUI
import Cepheus

struct SearchView: View {
    @State private var content: String = ""
    @State private var viewModel = SearchViewModel()
    @AppStorage("useCepheus") var useCepheus: Bool = true
    @AppStorage("jmurl") var jmurl = "https://qwasd12w-jmcomic-api.hf.space/v1"

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.results.isEmpty && !viewModel.hasSearched {
                    CepheusKeyboard(
                        input: $content,
                        prompt: "请输入要搜索的内容",
                        CepheusIsEnabled: useCepheus,
                        allowEmojis: false,
                        onSubmit: {
                            viewModel.searchQuery = content
                            Task { await viewModel.search(jmurl: jmurl) }
                        }
                    )
                } else if viewModel.isLoading && viewModel.results.isEmpty {
                    ProgressView("搜索中...")
                } else if let error = viewModel.errorMessage, viewModel.results.isEmpty {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                        Button("重试") {
                            Task { await viewModel.search(jmurl: jmurl) }
                        }
                    }
                } else {
                    List(viewModel.results) { album in
                        NavigationLink(destination: DetailView(jmurl: jmurl, album: album)) {
                            Text(album.title)
                        }
                    }
                }
            }
        }
    }
}
