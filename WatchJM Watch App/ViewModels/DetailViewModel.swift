//
//  DetailViewModel.swift
//  WatchJM
//

import SwiftUI

@Observable
final class DetailViewModel {
    var album: Album
    var isLoading = false
    var isDownloading = false
    var downloadProgress: Float = 0.0
    var errorMessage: String? = nil
    var coverURL: URL? = nil

    init(album: Album) {
        self.album = album
    }

    func loadInfo(jmurl: String) async {
        guard album.tags.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            album = try await Net.shared.getInfo(jmurl: jmurl, album: album)
        } catch {
            errorMessage = "加载信息失败: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func checkLocal(jmurl: String) {
        let file = File()
        do {
            album.url = try file.isExist(aid: album.aid)
            if album.url == nil {
                var normalized = jmurl
                while normalized.hasSuffix("/") {
                    normalized = String(normalized.dropLast())
                }
                coverURL = URL(string: "\(normalized)/get/cover/\(album.aid)")
            } else {
                coverURL = try file.coverFinder(aid: album.aid)
            }
        } catch {
            errorMessage = "加载封面失败: \(error.localizedDescription)"
            album.url = nil
        }
    }

    func startDownload(jmurl: String) async {
        isDownloading = true
        downloadProgress = 0.0
        errorMessage = nil
        do {
            album.url = try await Net.shared.downloadViaWebSocket(
                jmurl: jmurl,
                album: album
            ) { [weak self] (progress: Float) in
                self?.downloadProgress = progress
            }
        } catch {
            errorMessage = "下载失败: \(error.localizedDescription)"
        }
        isDownloading = false
        downloadProgress = 0.0
    }
}
