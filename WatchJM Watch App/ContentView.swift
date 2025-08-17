//
//  ContentView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/8/16.
//

import SwiftUI
import Cepheus

struct ContentView: View {
    let Checker = Net()
    @State var ms:String = ""
    var body: some View {
        Text("连接延迟:"+ms+"ms")
            .onAppear{
                Task {
                    do {
                        let currentDate = Date()
                        let timeInterval = currentDate.timeIntervalSince1970
                        ms = try await Checker.Check(jmurl: "http://192.168.31.42:11111/", timeInterval: timeInterval)
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
