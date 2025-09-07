//
//  FileManager.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//

import Foundation
import Zip

struct File {
    func unzip(zipFileURL: URL, album: Album) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        do {
            let unzippedFolderURL = try Zip.quickUnzipFile(zipFileURL)
            let finalUnzippedFolderURL = documentsDirectory.appendingPathComponent(album.aid, isDirectory: true)
            if fileManager.fileExists(atPath: finalUnzippedFolderURL.path) {
                try fileManager.removeItem(at: finalUnzippedFolderURL)
            }
            try fileManager.moveItem(at: unzippedFolderURL, to: finalUnzippedFolderURL)
            try fileManager.removeItem(at: zipFileURL)
            return finalUnzippedFolderURL
        } catch {
            throw error
        }
    }
    func isExist(album: Album) throws -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationZipURL = documentsDirectory.appendingPathComponent(album.aid,isDirectory: true)
        if fileManager.fileExists(atPath: destinationZipURL.path) {
            return destinationZipURL
        }
        return nil
    }
    func coverFinder(album: Album) throws -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationZipURL = documentsDirectory.appendingPathComponent(album.aid,isDirectory: true)
        let finalURL = destinationZipURL.appendingPathComponent("00001.webp")
        if fileManager.fileExists(atPath: finalURL.path) {
            print(finalURL)
            return finalURL
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }
}
