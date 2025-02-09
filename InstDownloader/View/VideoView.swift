//
//  VideoView.swift
//  InstDownloader
//
//  Created by wibus on 2024/11/2.
//
import SwiftUI

struct VideoRowView: View {
    let video: DynamicSpecListRow
    @State private var showDetail = false
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(video.specName)
                    .font(.headline)
                Text("作者: \(video.uploaderName)")
                    .font(.subheadline)
                Text("上传时间: \(video.uploaderTime)")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: favoritesViewModel.isFavorite(video.specId) ? "heart.fill" : "heart")
            }
        }
        .padding()
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            VideoDetailView(video: video)
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func toggleFavorite() {
        let favoriteSong = FavoriteSong(
            id: video.specId,
            name: video.specName,
            source: .zhibeizhe,
            uploadTime: Date(), // 需要将 uploaderTime 字符串转换为 Date
            songId: video.specId,
            songUrl: video.specUrl
        )
        
        if favoritesViewModel.isFavorite(video.specId) {
            favoritesViewModel.removeFavorite(favoriteSong)
        } else {
            favoritesViewModel.addFavorite(favoriteSong)
        }
    }
}

struct VideoDetailView: View {
    let video: DynamicSpecListRow
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var downloadManager = DownloadManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "chevron.left")
                    .onTapGesture {
                        dismiss()
                    }
                    .padding(.bottom)

                Text(video.specName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("作者: \(video.uploaderName)")
                Text("上传时间: \(video.uploaderTime)")
                Text("播放次数: \(video.playNum)")
                Text("下载次数: \(video.downloadNum)")
                Text("收藏次数: \(video.collectNum)")
                
                if !video.categoryName.isEmpty {
                    Text("分类: \(video.categoryName)")
                }
                
                HStack {
                    Button(audioPlayer.isPlaying ? "暂停" : "试听") {
                        audioPlayer.togglePlayPause(urlString: video.specUrl)
                    }
                    
                    Button("选择下载位置") {
                        downloadManager.selectDownloadDirectory()
                    }
                    
                    Button("下载") {
                        if downloadManager.downloadDirectory != nil {
                            downloadManager.downloadFile(from: video.noSpecUrl, fileName: "\(video.specName).mp4")
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
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
