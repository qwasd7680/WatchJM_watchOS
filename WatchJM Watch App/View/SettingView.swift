//
//  SettingView.swift
//  WatchJM Watch App
//
//  Created by 周敬博 on 2025/9/21.
//

import SwiftUI

struct SettingView: View {
    @State private var viewModel = SettingsViewModel()
    @AppStorage("jmurl") var jmurl: String = "https://qwasd12w-jmcomic-api.hf.space/v1"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API URL")) {
                    TextField("Enter JMComic API URL", text: $jmurl)
                    HStack {
                        Text("连接延迟: \(viewModel.latencyText)")
                        Spacer()
                        if viewModel.isChecking {
                            ProgressView()
                        } else {
                            Text(viewModel.latencyText.hasSuffix("ms") ? "✅" : "❌")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            Task { await viewModel.checkLatency(jmurl: jmurl) }
        }
        .onChange(of: jmurl) {
            Task { await viewModel.checkLatency(jmurl: jmurl) }
        }
    }
}

#Preview {
    SettingView()
}
