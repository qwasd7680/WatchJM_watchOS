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
    @State var downloadedAlbum:[URL?] = [nil]
    var body: some View {
        NavigationView {
            VStack{
                List(downloadedAlbum,id: \.self) { Album in
                    NavigationLink(destination: DownloadedDetailView(finderURL: Album)){
                        Text("1")
                    }
                }.onAppear{
                    do{
                        downloadedAlbum = try file.DownloadedAlbumFinder()
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
}

struct DownloadedDetailView: View {
//    @State var album: Album
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
                
//                Text(album.title)
//                    .font(.title3)
                NavigationLink(destination: ComicReaderView(folderURL: finderURL!)) {
                    Text("开始阅读")
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                }
            }
            .onAppear {
            }
        }
    }
}
