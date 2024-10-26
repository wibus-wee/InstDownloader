//
//  AudioPlayer.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/20.
//

import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var duration: Double = 0
    private var timeObserver: Any?
    @Published var currentUrl: String?

    func togglePlayPause(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        if urlString != currentUrl { // 如果当前播放的歌曲不是当前的歌曲，则暂停当前的歌曲, 并重置播放器
            player?.pause()
            isPlaying = false
            player = nil
            currentUrl = urlString
        }

        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil {
                player = AVPlayer(url: url)
                setupTimeObserver()
            }
            player?.play()
            isPlaying = true
        }
    }
    
    func seek(to progress: Double) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let time = CMTime(seconds: progress * duration.seconds, preferredTimescale: 600)
        player.seek(to: time)
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration else { return }
            self.duration = duration.seconds
            let progress = time.seconds / duration.seconds
            self.progress = progress
        }
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
}
