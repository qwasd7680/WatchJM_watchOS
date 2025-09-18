//
//  DownloadedView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/9/9.
//

import SwiftUI
import SDWebImageSwiftUI

struct DownloadedView: View {
    let file = File()
    @State var downloadedAlbumID: [String]?
    @State var downloadedAlbum: [Album?] = []
    var body: some View {
        NavigationView {
            VStack{
                if downloadedAlbum.isEmpty != true {
                    List(downloadedAlbum,id: \.self) { Album in
                        NavigationLink(destination: DownloadedDetailView(album: Album!, finderURL: file.DownloadedAlbumFinder(aid: Album!.aid))){
                            Text(Album?.title ?? "搜索中")
                        }
                    }
                }
            }.onAppear{
                downloadedAlbumID = file.getSubdirectories() ?? []
                for albumID in downloadedAlbumID! {
                    if downloadedAlbum.contains(file.JSON2Album(aid: albumID)) != true {
                        downloadedAlbum.append(file.JSON2Album(aid: albumID) ?? nil)
                    }
                }
            }
        }
    }
}

struct DownloadedDetailView: View {
    @State var album: Album
    @State var coverURL: URL? = nil
    @State var finderURL: URL?
    let file = File()
    var body: some View {
        ScrollView {
            VStack {
                WebImage(url: coverURL)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                
                Text(album.title)
                    .font(.title3)
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
                NavigationLink(destination: ComicReaderView(folderURL: finderURL!)) {
                    Text("开始阅读")
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                }
            }
            .onAppear {
                do {
                    coverURL = try file.coverFinder(album: album)
                } catch {
                    print(error)
                }
            }
        }
    }
}
