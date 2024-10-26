import SwiftUI

struct FiveSingRowView: View {
    let song: FiveSingSearchResult.SongInfo
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(song.songName)
                .font(.headline)
            Text("歌手: \(song.singer)")
                .font(.subheadline)
            Text("上传时间: \(song.createTime)")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            FiveSingDetailView(song: song)
        }
    }
}

struct FiveSingDetailView: View {
    let song: FiveSingSearchResult.SongInfo
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var downloadManager = DownloadManager()
    @Environment(\.dismiss) private var dismiss
    @StateObject private var fiveSingService = FiveSingService()
    @State private var songResult: FiveSingSongResult?
    
    var body: some View {
        ScrollView {
            if songResult == nil {
                VStack(alignment: .center) {
                    ProgressView()
                        .padding()
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "chevron.left")
                        .onTapGesture {
                            dismiss()
                        }
                        .padding(.bottom)

                    Text(song.songName)
                        .font(.title)
                        .fontWeight(.bold)
                
                    Text("歌手: \(song.singer)")
                    Text("上传时间: \(song.createTime)")
                
                    HStack {
                        Button(audioPlayer.isPlaying ? "暂停" : "试听") {
                            if let url = songResult?.data.hqurl {
                                audioPlayer.togglePlayPause(urlString: url)
                            }
                        }
                        .disabled(songResult == nil)
                    
                        Button("选择下载位置") {
                            downloadManager.selectDownloadDirectory()
                        }
                    
                        Button("下载") {
                            if let url = songResult?.data.hqurl, downloadManager.downloadDirectory != nil {
                                downloadManager.downloadFile(from: url, fileName: "\(song.songName).mp3")
                            } else {
                                print("请先选择下载位置或等待歌曲信息加载")
                            }
                        }
                        .disabled(downloadManager.isDownloading || downloadManager.downloadDirectory == nil || songResult == nil)
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
                            ), in: 0 ... 1)
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
        }
        .frame(width: 400, alignment: .leading)
        .onAppear {
            loadSongDetails()
        }
    }
    
    private func loadSongDetails() {
        Task {
            do {
                songResult = try await fiveSingService.song(songid: String(song.songId))
            } catch {
                print("加载歌曲详情失败: \(error)")
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = "加载歌曲详情失败: \(errorMessage)"
                    alert.runModal()
                }
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
