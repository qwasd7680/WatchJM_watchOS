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
    @State var isStartDownload = false
    @State var album:Album
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
                        Button(action: {
                            isStartDownload = true
                            Task {
                                do {
                                    album.url = try await NetWorkManager.downloadAlbum(jmurl: jmurl, album: album)
                                } catch {
                                    print("Error: \(error)")
                                }
                                isStartDownload = false
                            }
                        }, label: {
                            Text(isStartDownload ? "正在下载" : "开始下载")
                        })
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
