//
// DetailView.swift
// WatchJM
//
// Created by 周敬博 on 2025/8/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    var jmurl: String
    @State private var viewModel: DetailViewModel

    init(jmurl: String, album: Album) {
        self.jmurl = jmurl
        self._viewModel = State(initialValue: DetailViewModel(album: album))
    }

    var body: some View {
        ScrollView {
            VStack {
                // Cover image
                if let coverURL = viewModel.coverURL {
                    WebImage(url: coverURL)
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.bottom, 5)
                } else if viewModel.isLoading {
                    ProgressView()
                } else {
                    ProgressView()
                }

                Text(viewModel.album.title)
                    .font(.title3)

                // Tags
                if !viewModel.album.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.album.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }

                // Stats and download section (only when not already downloaded)
                if viewModel.album.url == nil {
                    if viewModel.isDownloading {
                        if viewModel.downloadProgress > 0 {
                            ProgressView(value: viewModel.downloadProgress)
                                .progressViewStyle(.linear)
                                .padding()
                            Text(String(format: "%.0f%%", viewModel.downloadProgress * 100))
                                .font(.caption)
                        } else {
                            ProgressView("等待服务器处理...")
                        }
                    }

                    HStack {
                        Image(systemName: "eye")
                        Text("\(viewModel.album.views)")
                        Spacer()
                        Image(systemName: "hand.thumbsup")
                        Text("\(viewModel.album.likes)")
                        Spacer()
                        if viewModel.album.method == "html" {
                            Image(systemName: "book.pages")
                            Text("\(viewModel.album.page_count)页")
                        }
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, 4)
                    }

                    // Download button
                    Button(action: {
                        Task { await viewModel.startDownload(jmurl: jmurl) }
                    }, label: {
                        Text(
                            viewModel.isDownloading
                                ? (viewModel.downloadProgress > 0 ? "正在下载" : "等待服务器端下载")
                                : "开始下载"
                        )
                    })
                    .disabled(viewModel.isDownloading)

                } else {
                    // Already downloaded — read button
                    if let url = viewModel.album.url {
                        NavigationLink(destination: ComicReaderView(folderURL: url)) {
                            Text("开始阅读")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadInfo(jmurl: jmurl)
                    viewModel.checkLocal(jmurl: jmurl)
                }
            }
        }
    }
}
