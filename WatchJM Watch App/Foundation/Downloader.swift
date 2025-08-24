//
//  Downloader.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/24.
//
import Foundation

class Downloader: NSObject, URLSessionDownloadDelegate {
    let originalURL: URL
    let fileName: String
    
    init(originalURL: URL,fileName: String) {
        self.originalURL = originalURL
        self.fileName = fileName
        super.init()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("下载完成！临时文件路径：\(location.path)")
        
        do {
            let fileManager = FileManager.default
            let documentsUrl = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationUrl = documentsUrl.appendingPathComponent(self.fileName)
            
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            
            try fileManager.moveItem(at: location, to: destinationUrl)
            print("文件已成功保存到：\(destinationUrl.path)")
            
        } catch {
            print("移动文件时出错：\(error.localizedDescription)")
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("下载进度：\(progress * 100)%")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("下载失败：\(error.localizedDescription)")
        } else {
            print("任务成功完成")
        }
    }
}
