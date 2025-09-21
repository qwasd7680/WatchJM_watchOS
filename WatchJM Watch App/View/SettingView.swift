//
//  SettingView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/9/21.
//

import SwiftUI

struct SettingView: View {
    let NetWorkManager = Net()
    @State var ms:String = "检查中..."
    @AppStorage("jmurl") var jmurl: String = "https://qwasd12w-jmcomic-api.hf.space/v1"

    var body: some View {
        NavigationView {
                Form {
                    Section(header: Text("API URL")) {
                        TextField("Enter JMComic API URL", text: $jmurl)
						HStack{
							Text("连接延迟: \(ms)")
							Spacer()
							Text(ms.hasSuffix("ms") ? "✅" : "❌")
						}
                    }
                }
                .navigationTitle("Settings")
        }
        .onAppear{
            Task{
                await checkLatency()
            }
        }
        .onChange(of: jmurl) {
            Task {
                await checkLatency()
            }
        }
    }
    
    private func checkLatency() async {
        self.ms = "检查中..."
        do {
            let currentDate = Date()
            let timeInterval = currentDate.timeIntervalSince1970 * 1000
            let latency = try await NetWorkManager.Check(jmurl: jmurl, timeInterval: timeInterval)
            self.ms = "\(latency)ms"
        } catch {
            self.ms = "无法连接"
            print("Latency Check Error: \(error)")
        }
    }
}

#Preview {
    SettingView()
}
