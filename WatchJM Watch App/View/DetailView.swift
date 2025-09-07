//
//  DetailView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/19.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    let NetWorkManager = Net()
    let file = File()
    var jmurl:String
    @State var fileurl:URL? = nil
    @State var isStartDownload = false
    @State var album:Album
    @State var isServerDownloaded = false
    @State var downloadProgress: Float = 0.0

    var body: some View{
        ScrollView{
            VStack{
                if album.cover != "" {
                    WebImage(url: URL(string:jmurl+"/get/cover/"+album.cover))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.bottom, 5)
                }else{
                    ProgressView()
                }
                Text(album.title)
                    .font(.title3)
                if album.tags != [""]{
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack{
                            ForEach(album.tags,id: \.self) {tag in
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
                    if album.url == nil {
                        if isStartDownload {
                            if isServerDownloaded {
                                ProgressView(value: downloadProgress)
                                    .progressViewStyle(.linear)
                                    .padding()
                                Text(String(format: "%.0f%%", downloadProgress * 100))
                                    .font(.caption)
                            } else {
                                ProgressView()
                            }
                        }
                        
                        Button(action: {
                            isStartDownload = true
                            Task {
                                do {
                                    (fileurl, isServerDownloaded) = try await NetWorkManager.startdownload(jmurl: jmurl, album: album)
                                } catch {
                                    print("Error: \(error)")
                                }
                                if isServerDownloaded {
                                    do {
                                        album.url = try await NetWorkManager.downloadAlbum(fileUrl: fileurl!, album: album) { progress in
                                            self.downloadProgress = progress
                                        }
                                    } catch {
                                        print("Download Error: \(error)")
                                    }
                                }
                                isStartDownload = false
                                self.downloadProgress = 0.0
                            }
                        }, label: {
                            Text(isStartDownload ? (isServerDownloaded ? "正在下载" : "等待服务器端下载") : "开始下载")
                        })
                        .disabled(isStartDownload)
                    } else {
                        NavigationLink(destination: ComicReaderView(folderURL: album.url!)) {
                            Text("开始阅读")
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                        }
                    }
                }
            }
        }.onAppear{
            if album.tags == [""]{
                Task{
                    do{
                        album = try await NetWorkManager.getInfo(jmurl: jmurl, album: album)
                    }catch{
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
}
