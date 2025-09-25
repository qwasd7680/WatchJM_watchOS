//
//  FileManager.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//

import Foundation
import Zip

/// `File` 结构体提供了一系列文件管理操作，主要用于处理专辑的下载、解压、存储和信息读取。
struct File {
    /// 解压指定的 ZIP 文件到应用程序的文档目录，并为专辑创建相应的文件夹。
    ///
    /// - Parameters:
    ///   - zipURL: 待解压的 ZIP 文件的本地 URL。
    ///   - album: 包含专辑信息的 `Album` 对象，用于命名解压后的文件夹和存储专辑 JSON。
    /// - Throws: 如果文件操作失败（例如，目录创建失败，解压失败），则抛出错误。
    /// - Returns: 解压后专辑文件夹的 URL。
    func unzip(_ zipURL: URL, album: Album) throws -> URL {
        let fileManager = FileManager.default
        
        // 获取应用程序的文档目录
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        // 构建存储所有下载专辑的父目录 URL
        let downloadedAlbumURL = documentsDirectory.appendingPathComponent("DownloadedAlbum")
        
        // 如果 DownloadedAlbum 目录不存在，则创建它
        if !fileManager.fileExists(atPath: downloadedAlbumURL.path) {
            try fileManager.createDirectory(at: downloadedAlbumURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 构建特定专辑的解压目标文件夹 URL (以 album.aid 命名)
        let finalUnzippedFolderURL = downloadedAlbumURL.appendingPathComponent(album.aid)
        
        // 如果目标文件夹已存在，则先删除它 (确保每次解压都是全新的)
        if fileManager.fileExists(atPath: finalUnzippedFolderURL.path) {
            try fileManager.removeItem(at: finalUnzippedFolderURL)
        }
        
        // 使用 Zip 库解压文件到指定的目标文件夹
        try Zip.unzipFile(zipURL, destination: finalUnzippedFolderURL, overwrite: true, password: nil)
        
        // 解压完成后，删除原始的 ZIP 文件
        try fileManager.removeItem(at: zipURL)
        
        // 将专辑信息保存为 JSON 文件到解压后的专辑文件夹中
        Album2JSON(album: album)
        
        return finalUnzippedFolderURL
    }
    
    /// 检查特定JM号对应的文件夹是否存在于文档目录中。
    ///
    /// - Parameter aid: 用于寻找该专辑是否存在
    /// - Throws: 如果获取文档目录失败，则抛出错误。
    /// - Returns: 如果专辑文件夹存在，则返回其 URL；否则返回 `nil`。
	func isExist(aid: String) throws -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        // 构建 DownloadedAlbum 目录的 URL
        let downloadedAlbumURL = documentsDirectory.appendingPathComponent("DownloadedAlbum", isDirectory: true)
        
        // 构建目标专辑文件夹的 URL，使用 album.aid
        let destinationAlbumURL = downloadedAlbumURL.appendingPathComponent(aid, isDirectory: true)
        
        // 检查该路径是否存在
        if fileManager.fileExists(atPath: destinationAlbumURL.path) {
            return destinationAlbumURL
        }
        return nil
    }
    
    /// 查找特定JM号的封面图片（cover.jpg）的 URL。
    ///
    /// - Parameter aid: JM号。
    /// - Throws: 如果文件不存在，则抛出 `URLError.fileDoesNotExist` 错误；如果文件系统操作失败，则抛出其他错误。
    /// - Returns: 如果封面图片存在，则返回其 URL。
	func coverFinder(aid: String) throws -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        // 构建 DownloadedAlbum 目录的 URL
        let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
        
        // 构建特定专辑文件夹的 URL，使用 album.aid
        let url = destinationURL.appendingPathComponent(aid,isDirectory: true)
        
        // 构建封面图片 `cover.jpg` 的完整 URL
        let finalURL = url.appendingPathComponent("cover.jpg")
        
        // 检查封面图片是否存在
        if fileManager.fileExists(atPath: finalURL.path) {
            return finalURL
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }
    
    /// 获取特定 `aid` 专辑的下载文件夹的 URL。
    ///
    /// - Parameter aid: JM号。
    /// - Returns: 专辑下载文件夹的 URL。如果文档目录创建失败，则会引发运行时错误。
    func DownloadedAlbumFinder(aid: String) -> URL? {
        let fileManager = FileManager.default
        // 获取文档目录，如果不存在则创建，并强制解包 URL
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        // 构建 DownloadedAlbum 目录的 URL
        let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
        
        // 构建特定专辑文件夹的 URL
        let url = destinationURL.appendingPathComponent(aid, isDirectory: true)
        return url
    }
    
    /// 将 `Album` 对象编码为 JSON 数据，并将其保存到指定专辑文件夹中的 `albumInfo.json` 文件。
    ///
    /// - Parameters:
    ///   - album: 要保存的 `Album` 对象。
    func Album2JSON(album: Album) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 格式化输出 JSON，使其易读
            let jsonData = try encoder.encode(album) // 将 Album 对象编码为 Data
            
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // 构建 DownloadedAlbum 目录的 URL
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
            
            // 构建特定专辑文件夹的 URL
			let albumDirectoryURL = destinationURL.appendingPathComponent(album.aid)
            
            // 如果专辑文件夹不存在，则创建它
            try fileManager.createDirectory(at: albumDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            // 构建 `albumInfo.json` 文件的完整 URL
            let fileURL = albumDirectoryURL.appendingPathComponent("albumInfo.json")
            
            // 将 JSON 数据写入文件
            try jsonData.write(to: fileURL, options: .atomic) // 使用 atomic 写入确保文件完整性
        } catch {
            print("创建专辑 JSON 文件时出错: \(error.localizedDescription)")
        }
    }
    
    /// 从特定 `aid` 专辑文件夹中的 `albumInfo.json` 文件读取数据，并将其解码为 `Album` 对象。
    ///
    /// - Parameter aid: JM号。
    /// - Returns: 如果成功读取并解码，则返回 `Album` 对象；否则返回 `nil` 并打印错误。
    func JSON2Album(aid: String) -> Album? {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 构建 DownloadedAlbum 目录的 URL
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum",isDirectory: true)
            
            // 构建特定专辑文件夹的 URL
            let url = destinationURL.appendingPathComponent(aid,isDirectory: true)
            
            // 构建 `albumInfo.json` 文件的完整 URL
            let fileURL = url.appendingPathComponent("albumInfo.json")
            
            // 从文件读取 JSON 数据
            let jsonData = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            let album = try decoder.decode(Album.self, from: jsonData) // 将 Data 解码为 Album 对象
            return album
        } catch {
            print(error) // 打印解码或文件读取错误
            return nil
        }
    }
    
    /// 获取 `DownloadedAlbum` 目录下的所有子目录（即已下载专辑的 ID 列表）。
    ///
    /// - Returns: 包含所有专辑 ID 字符串的数组，如果操作失败或没有子目录，则返回 `nil`。
    func getSubdirectories() -> [String]? {
        let fileManager = FileManager.default
        var subdirectoryNames = [String]()
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 构建 DownloadedAlbum 目录的 URL
            let destinationURL = documentsDirectory.appendingPathComponent("DownloadedAlbum")
            
            // 如果 DownloadedAlbum 目录不存在，则创建它
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            // 获取 DownloadedAlbum 目录下的所有内容，并请求是否为目录的信息
            let contents = try fileManager.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            
            // 遍历所有内容，筛选出子目录的名称
            for item in contents {
                let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
                if let isDirectory = resourceValues.isDirectory, isDirectory {
                    subdirectoryNames.append(item.lastPathComponent) // 添加子目录的名称（即专辑 ID）
                }
            }
            return subdirectoryNames
        } catch {
            print(error.localizedDescription) // 打印错误信息
            return nil
        }
    }
}
