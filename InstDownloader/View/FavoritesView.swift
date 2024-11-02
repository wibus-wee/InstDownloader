import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var fiveSingService = FiveSingService()
    
    var body: some View {
        VStack(alignment: .leading) {
          VStack(alignment: .leading) {
                    Text("收藏列表")
                        .font(.title2)
                        .bold()

                    Text("查看收藏的伴奏歌曲列表")
                        .font(.caption)
                        .foregroundColor(.secondary)
            }
            .padding()

            ScrollView {
                LazyVStack {
                    ForEach(favoritesViewModel.favorites) { favorite in
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text(favorite.name)
                                    .font(.headline)
                                Text("来源: \(favorite.source.rawValue)")
                                    .font(.subheadline)
                                Text("上传时间: \(formatDate(favorite.uploadTime))")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                            HStack {
                                Button("删除") {
                                    favoritesViewModel.removeFavorite(favorite)
                                }

                                Button(action: {
                                    playPreview(favorite)
                                }) {
                                    // Image(systemName: "play.fill")
                                    if audioPlayer.isPlaying && audioPlayer.currentUrl == favorite.songUrl {
                                        Image(systemName: "pause.fill")
                                    } else {
                                        Image(systemName: "play.fill")
                                    }
                                }
                            
                                Button("下载") {
                                    downloadSong(favorite)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .padding()
            }
            FooterView()
        }
        .background(.regularMaterial)
        .frame(width: 350, height: 450)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            favoritesViewModel.removeFavorite(favoritesViewModel.favorites[index])
        }
    }
    
    private func playPreview(_ favorite: FavoriteSong) {
        if favorite.source == .fiveSing {
            Task {
                do {
                    let songResult = try await fiveSingService.song(songid: favorite.songId)
                    let url = songResult.data.hqurl
                    audioPlayer.togglePlayPause(urlString: url)
                } catch {
                    print("加载5Sing歌曲失败: \(error)")
                }
            }
        } else if favorite.source == .zhibeizhe {
            if let url = favorite.songUrl {
                audioPlayer.togglePlayPause(urlString: url)
            } else {
                print("无效的URL: \(favorite.songUrl)")
            }
        }
    }
    
    private func downloadSong(_ favorite: FavoriteSong) {
        if favorite.source == .fiveSing {
            Task {
                do {
                    let songResult = try await fiveSingService.song(songid: favorite.songId)
                    let url = songResult.data.hqurl
                    downloadManager.downloadFile(from: url, fileName: "\(favorite.name).mp3")
                } catch {
                    print("加载5Sing歌曲失败: \(error)")
                }
            }
        } else if favorite.source == .zhibeizhe {
            if let url = favorite.songUrl {
                downloadManager.selectDownloadDirectory()
                downloadManager.downloadFile(from: url, fileName: "\(favorite.name).mp3")
            } else {
                print("无效的URL: \(favorite.songUrl)")
            }
        }
    }
}

//#Preview {
//    FavoritesView()
//        .environmentObject(FavoritesViewModel())
//}
