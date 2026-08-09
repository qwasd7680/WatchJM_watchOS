//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct MainView: View {
    let rankList: [Album]
    let jmurl: String
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () -> Void
    @State var isGoToSearch = false

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("加载中...")
                } else if let error = errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        Button("重试") {
                            onRetry()
                        }
                    }
                    .padding()
                } else if rankList.isEmpty {
                    Text("暂无排行数据")
                        .foregroundStyle(.secondary)
                } else {
                    List(rankList) { album in
                        NavigationLink(destination: DetailView(jmurl: jmurl, album: album)) {
                            Text(album.title)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isGoToSearch = true
                    }) {
                        Label("搜索", systemImage: "magnifyingglass")
                    }
                    .sheet(isPresented: $isGoToSearch) {
                        SearchView()
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var viewModel = RankingsViewModel()
    @AppStorage("jmurl") var jmurl = "https://qwasd12w-jmcomic-api.hf.space/v1"

    var body: some View {
        TabView {
            MainView(
                rankList: viewModel.rankList,
                jmurl: jmurl,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                onRetry: {
                    Task { await viewModel.loadRankings(jmurl: jmurl) }
                }
            )
            .tag(0)
            .onAppear {
                if viewModel.rankList.isEmpty && !viewModel.isLoading {
                    Task { await viewModel.loadRankings(jmurl: jmurl) }
                }
            }

            DownloadedView()
                .tag(1)

            SettingView()
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
