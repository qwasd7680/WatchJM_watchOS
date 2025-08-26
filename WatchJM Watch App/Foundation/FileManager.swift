//
//  FileManager.swift
//  WatchJM
//
//  Created by 周敬博 on 2025/8/26.
//

import Foundation
import Zip

struct File {
    func unzip(zipFileURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationZipURL = documentsDirectory.appendingPathComponent(zipFileURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationZipURL.path) {
                try fileManager.removeItem(at: destinationZipURL)
            }
            try fileManager.moveItem(at: zipFileURL, to: destinationZipURL)
            let destinationPath = try Zip.quickUnzipFile(destinationZipURL)
            try fileManager.removeItem(at: destinationZipURL)
            return destinationPath
        } catch {
            throw error
        }
    }
}
