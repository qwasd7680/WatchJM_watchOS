//
//  FileManager.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//

import Foundation
import Zip

struct File {
    func unzip(_ zipURL: URL, album: Album) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let downloadedAlbumURL = documentsDirectory.appendingPathComponent("DownloadedAlbum")
        if !fileManager.fileExists(atPath: downloadedAlbumURL.path) {
            try fileManager.createDirectory(at: downloadedAlbumURL, withIntermediateDirectories: true, attributes: nil)
        }
        let finalUnzippedFolderURL = downloadedAlbumURL.appendingPathComponent(album.aid)
        if fileManager.fileExists(atPath: finalUnzippedFolderURL.path) {
            try fileManager.removeItem(at: finalUnzippedFolderURL)
        }
        try Zip.unzipFile(zipURL, destination: finalUnzippedFolderURL, overwrite: true, password: nil)
        try fileManager.removeItem(at: zipURL)
        return finalUnzippedFolderURL
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
            return finalURL
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }
    func DownloadedAlbumFinder() throws -> [URL?] {
        var tmp:[URL?] = []
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
        let contents = try fileManager.contentsOfDirectory(at: destinationURL,includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
        for item in contents {
            tmp.append(item)
        }
        return tmp
    }
}
