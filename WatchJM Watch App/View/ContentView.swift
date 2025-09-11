//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct MainView: View {
    let rankList:[Album]
    var jmurl:String
    @State var ms:String
    @State var isGoToSearch = false
    var body: some View {
        NavigationView {
            VStack{
                Text("连接延迟:"+ms+"ms")
                List(rankList) { list in
                    NavigationLink(destination: DetailView(jmurl: jmurl, album: list)){
                        Text(list.title)
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isGoToSearch = true
                }) {
                    Label("搜索", systemImage: "magnifyingglass")
                }.sheet(isPresented: $isGoToSearch, content: {SearchView()})
            }
        }
    }
}

struct ContentView: View {
    @State var rankList:[Album] = []
    @State var ms:String = ""
    var jmurl:String = "https://qwasd12w-jmcomic-api.hf.space"
    let NetWorkManager = Net()
    var body: some View {
        NavigationStack{
            TabView{
                MainView(rankList: rankList, jmurl: jmurl, ms: ms)
                    .tag(0)
                    .onAppear{
                        Task{
                            do {
                                rankList = try await NetWorkManager.GetRank(jmurl: jmurl)
                                let currentDate = Date()
                                let timeInterval = currentDate.timeIntervalSince1970 * 1000
                                ms = try await NetWorkManager.Check(jmurl: jmurl, timeInterval: timeInterval)
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                DownloadedView()
                    .tag(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
