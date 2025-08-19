//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct ContentView: View {
    let NetWorkManager = Net()
    @State var rankList:[Album] = []
    @State var ms:String = ""
    var body: some View {
        NavigationView {
            VStack{
                Text("连接延迟:"+ms+"ms")
                    List(rankList) { list in
                        NavigationLink(destination: DetailView(album: list)){
                        Text(list.title)
                    }
                }
            }
        }
        .onAppear{
            Task {
                do {
                    let currentDate = Date()
                    let timeInterval = currentDate.timeIntervalSince1970
                    ms = try await NetWorkManager.Check(jmurl: "http://192.168.31.42:11111/", timeInterval: timeInterval)
                } catch {
                    print("Error: \(error)")
                }
                do {
                    rankList = try await NetWorkManager.GetRank(jmurl: "http://192.168.31.42:11111/")
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
