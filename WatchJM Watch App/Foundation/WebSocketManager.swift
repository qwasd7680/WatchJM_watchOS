//
//  WebSocketManager.swift
//  WatchJM
//
//  Created by Maverick Charmer on 2025/9/30.
//

import Foundation

// MARK: - 1. WebSocket 通知的数据结构

/// WebSocket 推送的下载通知结构
struct WebSocketNotification: Decodable {
    let status: String       // 例如: "download_ready"
    let file_name: String?   // 只有 status 为 "download_ready" 时才有值
    let message: String
}

// MARK: - 2. Delegate 协议

/// WebSocketManager 的代理协议，用于向调用者发送实时通知
protocol WebSocketDelegate: AnyObject {
    /**
     当接收到服务器推送的下载准备完成通知时调用。

     - Parameters:
       - manager: 触发事件的 WebSocketManager 实例。
       - notification: 包含文件名的通知数据。
     */
    func webSocketDidReceiveDownloadReady(manager: WebSocketManager, notification: WebSocketNotification)
    
    /**
     当 WebSocket 连接状态发生变化时调用。
     
     - Parameters:
       - manager: 触发事件的 WebSocketManager 实例。
       - isConnected: 当前连接状态。
     */
    func webSocketConnectionStatusDidChange(manager: WebSocketManager, isConnected: Bool)
}

// MARK: - 3. WebSocket 管理类

class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    
    weak var delegate: WebSocketDelegate?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let jmurl: String
    private let clientID: String
    
    // 实例化时传入 API 地址和客户端 ID
    init(jmurl: String, clientID: String) {
        self.jmurl = jmurl
        self.clientID = clientID
        super.init()
    }
    
    /// 建立 WebSocket 连接
    func connect() {
        // 1. 将 HTTP URL (http://...) 转换为 WebSocket URL (ws://...)
        var wsURLString = jmurl.replacingOcculating("http://", with: "ws://")
        wsURLString = wsURLString.replacingOcculating("https://", with: "wss://")
        
        // 2. 构造完整的 WebSocket Endpoint: /ws/notifications/{client_id}
        guard let url = URL(string: wsURLString + "/ws/notifications/" + clientID) else {
            print("WebSocket URL 无效: \(wsURLString + "/ws/notifications/" + clientID)")
            return
        }
        
        // 3. 创建 URLSession 和 WebSocket Task
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        
        // 4. 恢复 (启动) 连接
        webSocketTask?.resume()
        print("尝试连接 WebSocket: \(url.absoluteString)")
        
        // 5. 启动监听循环
        receiveMessage()
    }
    
    /// 断开 WebSocket 连接
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        print("WebSocket 连接已断开.")
        delegate?.webSocketConnectionStatusDidChange(manager: self, isConnected: false)
    }
    
    /// 递归监听服务器推送的消息
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("WebSocket 接收错误: \(error)")
                self.delegate?.webSocketConnectionStatusDidChange(manager: self, isConnected: false)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleReceivedText(text)
                case .data(let data):
                    print("收到二进制数据，忽略: \(data.count) bytes")
                @unknown default:
                    break
                }
                // 收到消息后，继续监听下一条消息
                self.receiveMessage()
            }
        }
    }
    
    /// 处理接收到的 JSON 文本消息
    private func handleReceivedText(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("无法将接收到的字符串解码为数据。")
            return
        }
        
        do {
            let notification = try JSONDecoder().decode(WebSocketNotification.self, from: data)
            print("收到通知: \(notification)")
            
            // 检查是否是下载完成通知
            if notification.status == "download_ready", notification.file_name != nil {
                DispatchQueue.main.async {
                    self.delegate?.webSocketDidReceiveDownloadReady(manager: self, notification: notification)
                }
            }
            // 可以添加其他状态 (如 progress_update) 的处理
            
        } catch {
            print("WebSocket JSON 解析失败: \(error.localizedDescription)\n原始数据: \(text)")
        }
    }
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket 已连接.")
        DispatchQueue.main.async {
            self.delegate?.webSocketConnectionStatusDidChange(manager: self, isConnected: true)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket 已断开. Code: \(closeCode.rawValue)")
        DispatchQueue.main.async {
            self.delegate?.webSocketConnectionStatusDidChange(manager: self, isConnected: false)
        }
    }
}

// MARK: - String 扩展 (替换 http/https 为 ws/wss)
extension String {
    func replacingOcculating(_ target: String, with replacement: String) -> String {
        return self.replacingOccurrences(of: target, with: replacement, options: .caseInsensitive)
    }
}
