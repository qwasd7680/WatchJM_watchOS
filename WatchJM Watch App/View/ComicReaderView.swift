//
//  ComicReaderView.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//


import SwiftUI
import SDWebImageSwiftUI

struct ComicReaderView: View {
    let folderURL: URL

    @State private var webpURLs: [URL] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("加载中...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if webpURLs.isEmpty {
                Text("未找到任何 webp 文件。")
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(webpURLs, id: \.self) { url in
                            ZoomableImageView(imageURL: url)
                        }
                    }
                }
            }
        }
        .task {
            await loadWebPFiles()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadWebPFiles() async {
        let fileManager = FileManager.default
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            
            let sortedURLs = fileURLs
                .filter { $0.pathExtension.lowercased() == "webp" }
                .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            
            self.webpURLs = sortedURLs
            self.isLoading = false
            
        } catch {
            self.errorMessage = "加载失败: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
