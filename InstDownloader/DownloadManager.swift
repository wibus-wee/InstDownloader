//
//  DownloadManager.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/20.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DirectoryPicker {
    static func selectDirectory(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "选择下载位置"
        
        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
    }
}

class DownloadManager: ObservableObject {
    @Published var progress: Float = 0
    @Published var isDownloading = false
    @Published var downloadDirectory: URL?

    func selectDownloadDirectory() {
        DirectoryPicker.selectDirectory { url in
            DispatchQueue.main.async {
                self.downloadDirectory = url
            }
        }
    }

    func downloadFile(from urlString: String, fileName: String) {
        guard let url = URL(string: urlString),
              let downloadDirectory = downloadDirectory else { return }
        
        isDownloading = true
        
        let destinationURL = downloadDirectory.appendingPathComponent(fileName)

        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("文件已存在: \(destinationURL.path)")
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "文件已存在: \(destinationURL.path). 你可能需要删除文件后重新下载"
                alert.runModal()
            }
            isDownloading = false
            return
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] localURL, _, error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                self?.progress = 0
                self?.progressObservation = nil  // 清除观察对象
                
                if let error = error {
                    print("下载错误: \(error)")
                    return
                }
                
                guard let localURL = localURL else { return }
                
                do {
                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    print("文件已下载到: \(destinationURL.path)")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .informational
                        alert.messageText = "文件已下载到: \(destinationURL.path)"
                        alert.runModal()
                    }
                } catch {
                    print("保存文件时出错: \(error)")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "保存文件时出错: \(error)"
                        alert.runModal()
                    }
                }
            }
        }
        
        // 添加进度观察
        downloadTask.resume()
        
        let observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.progress = Float(progress.fractionCompleted)
            }
        }
        
        // 保存观察对象以防止被过早释放
        self.progressObservation = observation
    }
    
    // 添加一个属性来保存进度观察对象
    private var progressObservation: NSKeyValueObservation?
}
