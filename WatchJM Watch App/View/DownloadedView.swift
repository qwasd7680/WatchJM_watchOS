//
//  DownloadedView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/9/9.
//

import SwiftUI
import SDWebImageSwiftUI

struct DownloadedView: View {
    @State private var viewModel = DownloadedViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else if viewModel.albums.isEmpty {
                    Text("暂无已下载的本子")
                        .foregroundStyle(.secondary)
                } else {
                    List(viewModel.albums) { album in
                        let finderURL = File().DownloadedAlbumFinder(aid: album.aid)
                        if let finderURL = finderURL {
                            NavigationLink(destination: DownloadedDetailView(album: album, finderURL: finderURL)) {
                                Text(album.title)
                            }
                        } else {
                            Text(album.title)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadDownloadedAlbums()
            }
        }
    }
}

struct DownloadedDetailView: View {
    @State var album: Album
    @State private var coverURL: URL? = nil
    let finderURL: URL
    let file = File()

    var body: some View {
        ScrollView {
            VStack {
                if let coverURL = coverURL {
                    WebImage(url: coverURL)
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.bottom, 5)
                } else {
                    ProgressView()
                }

                Text(album.title)
                    .font(.title3)

                if !album.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(album.tags, id: \.self) { tag in
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

                NavigationLink(destination: ComicReaderView(folderURL: finderURL)) {
                    Text("开始阅读")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .onAppear {
                do {
                    coverURL = try file.coverFinder(aid: album.aid)
                } catch {
                    print("Cover finder error: \(error)")
                }
            }
        }
    }
}
