//
//  DownloadedViewModel.swift
//  WatchJM
//

import SwiftUI

@Observable
final class DownloadedViewModel {
    var albums: [Album] = []
    var isLoading = false

    func loadDownloadedAlbums() {
        isLoading = true
        let file = File()
        let albumIDs = file.getSubdirectories() ?? []
        var loaded: [Album] = []
        for aid in albumIDs {
            if let album = file.JSON2Album(aid: aid) {
                loaded.append(album)
            }
        }
        albums = loaded
        isLoading = false
    }
}
