//
//  Network.swift
//  WatchJM
//
//  Created by Maverick Charmer on 2025/8/17.
//

import Foundation
import SwiftyJSON
import Alamofire

class Net{
	func Check(jmurl:String) async throws -> String {
		let currentDate = Date()
		let timeInterval = currentDate.timeIntervalSince1970 * 1000
		var latency = ""
		guard let url = URL(string: jmurl+"/"+String(timeInterval)) else {
			throw URLError(.badURL)
		}
		AF.request(url).responseDecodable(of: CheckNet.self) { response in
			switch response.result{
			case .success(let data):
				latency = data.latency
			case .failure(let error):
				print(error)
			}
		}
		return latency
	}
	func GetRank(time:String, jmurl:String) async throws -> [Album] {
		var tempList:[Album] = []
		guard let url = URL(string: jmurl+"/rank/"+time) else {
			throw URLError(.badURL)
		}
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
			throw URLError(.badServerResponse)
		}
		let json = try! JSON(data: data)
		for dic in json {
			tempList.append(Album(id: UUID(), title: dic.1["title"].string!, aid: dic.1["aid"].string!))
		}
		return tempList
	}
	func getInfo(jmurl:String, album:Album) async throws -> Album{
		var albumInfo: AlbumInfo? = nil
		guard let url = URL(string: jmurl+"/info/"+album.aid) else {
			throw URLError(.badURL)
		}
		AF.request(url).responseDecodable(of: AlbumInfo.self) { response in
			switch response.result {
			case .success(let data):
				albumInfo = data
			case .failure(let error):
				print(error)
			}
		}
		return mixInfo(Info: albumInfo!, album:album)
	}
	func initiateDownloadTask(jmurl: String, albumID: String, clientID: String) async throws -> DownloadTaskInitiationResponse {
		var responseModel:DownloadTaskInitiationResponse? = nil
		guard let url = URL(string: jmurl + "/v1/download/album/" + albumID) else {
			throw URLError(.badURL)
		}
		let parameters: [String:Any] = [
			"client_id":clientID
		]
		AF.request(url, method: .post, parameters: parameters).responseDecodable(of: DownloadTaskInitiationResponse.self) { response in
			switch response.result {
			case .success(let data):
				responseModel = data
			case .failure(let error):
				print(error)
			}
		}
		return responseModel!
	}
	func downloadAlbum(jmurl: String, fileName: String, album: Album, progressHandler: @escaping (Double) -> Void) async throws -> URL {
		//TODO: 中断后下载
//		var resumeData: Data?
		guard let url = URL(string: jmurl + "/v1/download/" + fileName) else {
			throw URLError(.badURL)
		}
		let file = File()
		let tempDestinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).zip")
		let destination: DownloadRequest.Destination = { _, _ in
			return (tempDestinationURL, [.removePreviousFile, .createIntermediateDirectories])
		}
		AF.download(url, to: destination).downloadProgress { progress in
			DispatchQueue.main.async {
				progressHandler(progress.fractionCompleted)
			}
		}/*.response { response in
			if let error = response.error {
				resumeData = response.resumeData
				print("下载失败，错误：\(error)")
			} else if let fileURL = response.fileURL {
				print("文件下载至：\(fileURL)")
			}
		}
		
		// 恢复下载
		if let resumeData = resumeData {
			AF.download(resumingWith: resumeData, to: destination).response { response in
				if let error = response.error {
					print("恢复失败，错误：\(error)")
				} else if let fileURL = response.fileURL {
					print("文件下载至：\(fileURL)")
				}
			}
		}*/
		return try file.unzip(tempDestinationURL, album: album)
	}
}
