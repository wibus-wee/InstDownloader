//
//  AccompanyListView.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/24.
//

import SwiftUI
import WindowAnimation


struct AccompanyRowView: View {
    let accompany: AccompanyListRow
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(accompany.accName)
                .font(.headline)
            Text("作者: \(accompany.accUserName)")
                .font(.subheadline)
            Text("上传时间: \(formatDate(accompany.accTime))")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            AccompanyDetailView(accompany: accompany)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct AccompanyDetailView: View {
    let accompany: AccompanyListRow
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var downloadManager = DownloadManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Button("返回") {
                //     dismiss()
                // }
                // .padding(.bottom)
                Image(systemName: "chevron.left")
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.bottom)

                Text(accompany.accName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("作者: \(accompany.accUserName)")
                Text("上传时间: \(formatDate(accompany.accTime))")
                Text("播放次数: \(accompany.playNum)")
                Text("下载次数: \(accompany.downloadNum)")
                Text("收藏次数: \(accompany.collectNum)")
                
                if let category = accompany.categoryName {
                    Text("分类: \(category)")
                }
                
                if let author = accompany.accAuthor {
                    Text("原唱: \(author)")
                }
                
                HStack {
                    Button(audioPlayer.isPlaying ? "暂停" : "试听") {
                        audioPlayer.togglePlayPause(urlString: accompany.accFileUrl)
                    }
                    
                    Button("选择下载位置") {
                        downloadManager.selectDownloadDirectory()
                    }
                    
                    Button("下载") {
                        if downloadManager.downloadDirectory != nil {
                            downloadManager.downloadFile(from: accompany.accFileUrl, fileName: "\(accompany.accName).mp3")
                        } else {
                            print("请先选择下载位置")
                        }
                    }
                    .disabled(downloadManager.isDownloading || downloadManager.downloadDirectory == nil)
                }
                
                if let directory = downloadManager.downloadDirectory {
                    Text("下载位置: \(directory.path)")
                        .font(.caption)
                }
                
                if downloadManager.isDownloading {
                    ProgressView(value: downloadManager.progress)
                }
                
                if audioPlayer.isPlaying || audioPlayer.progress > 0 {
                    VStack {
                        Slider(value: Binding(
                            get: { self.audioPlayer.progress },
                            set: { newValue in
                                self.audioPlayer.seek(to: newValue)
                            }
                        ), in: 0...1)
                        .accentColor(.blue)
                        
                        HStack {
                            Text(formatTime(audioPlayer.progress * audioPlayer.duration))
                            Spacer()
                            Text(formatTime(audioPlayer.duration))
                        }
                        .font(.caption)
                    }
                }
            }
            .padding()
        }
        .frame(width: 400, alignment: .leading)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
