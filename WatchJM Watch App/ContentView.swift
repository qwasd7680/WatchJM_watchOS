//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct ContentView: View {
    var jmurl:String = "http://127.0.0.1:8000"
    let NetWorkManager = Net()
    @State var rankList:[Album] = []
    @State var ms:String = ""
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
        }
        .onAppear{
            Task {
                do {
                    let currentDate = Date()
                    let timeInterval = currentDate.timeIntervalSince1970
                    ms = try await NetWorkManager.Check(jmurl: jmurl, timeInterval: timeInterval)
                } catch {
                    print("Error: \(error)")
                }
                do {
                    rankList = try await NetWorkManager.GetRank(jmurl: jmurl)
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
