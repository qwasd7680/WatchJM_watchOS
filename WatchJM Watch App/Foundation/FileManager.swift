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
        Album2JSON(album: album, aid: album.aid)
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
        let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
        let url = destinationURL.appendingPathComponent(album.aid,isDirectory: true)
        let finalURL = url.appendingPathComponent("00001.webp")
        if fileManager.fileExists(atPath: finalURL.path) {
            return finalURL
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }
    func DownloadedAlbumFinder(aid: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
        let url = destinationURL.appendingPathComponent(aid, isDirectory: true)
        return url
    }
    func Album2JSON(album: Album, aid: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(album)
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
            let albumDirectoryURL = destinationURL.appendingPathComponent(aid)
            try fileManager.createDirectory(at: albumDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = albumDirectoryURL.appendingPathComponent("albumInfo.json")
            try jsonData.write(to: fileURL, options: .atomic)
            
        } catch {
            print("创建专辑 JSON 文件时出错: \(error.localizedDescription)")
        }
    }
    func JSON2Album(aid: String) -> Album? {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
            let url = destinationURL.appendingPathComponent(aid,isDirectory: true)
            let fileURL = url.appendingPathComponent("albumInfo.json")
            let jsonData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let album = try decoder.decode(Album.self, from: jsonData)
            return album
        } catch {
            print(error)
            return nil
        }
    }
    func getSubdirectories() -> [String]? {
        let fileManager = FileManager.default
        var subdirectoryNames = [String]()
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum")
            let contents = try fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            for item in contents {
                let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
                if let isDirectory = resourceValues.isDirectory, isDirectory {
                    subdirectoryNames.append(item.lastPathComponent)
                }
            }
            return subdirectoryNames
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
