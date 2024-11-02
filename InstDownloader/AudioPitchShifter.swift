//
//  AudioPitchShifter.swift
//  InstDownloader
//
//  Created by wibus-wee on 2024/11/02.
//

import AVFoundation

class AudioPitchShifter: ObservableObject {
    @Published var isProcessing = false
    @Published var progress: Float = 0

    func shiftPitch(inputURL: URL, semitones: Int, completion: @escaping (Result<URL, Error>) -> Void) {
        isProcessing = true
        progress = 0

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        do {
            // 读取输入文件
            let file = try AVAudioFile(forReading: inputURL)
            let format = file.processingFormat

            // 创建离线引擎
            let engine = AVAudioEngine()
            let playerNode = AVAudioPlayerNode()
            let pitchNode = AVAudioUnitTimePitch()

            pitchNode.pitch = Float(semitones * 100)

            engine.attach(playerNode)
            engine.attach(pitchNode)

            engine.connect(playerNode, to: pitchNode, format: format)
            engine.connect(pitchNode, to: engine.mainMixerNode, format: format)

            // 读取整个文件到buffer
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
            try file.read(into: buffer)

            // 设置离线渲染模式
            try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
            
            // 调度buffer
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            
            // 启动引擎和播放节点
            try engine.start()
            playerNode.play()

            // 创建输出文件
            let outputFile = try AVAudioFile(
                forWriting: outputURL,
                settings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: format.sampleRate,
                    AVNumberOfChannelsKey: format.channelCount,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                ]
            )

            // 离线渲染
            try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
            try engine.start()

            let outputBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                                frameCapacity: engine.manualRenderingMaximumFrameCount)!

            let totalFrames = buffer.frameLength
            var processedFrames: AVAudioFrameCount = 0

            while processedFrames < totalFrames {
                let framesToRender = min(4096, totalFrames - processedFrames)
                let status = try engine.renderOffline(framesToRender, to: outputBuffer)

                switch status {
                case .success:
                    try outputFile.write(from: outputBuffer)
                    processedFrames += framesToRender

                    DispatchQueue.main.async {
                        self.progress = Float(processedFrames) / Float(totalFrames)
                    }
                case .error, .insufficientDataFromInputNode:
                    throw NSError(domain: "AudioProcessingError", code: -1)
                case .cannotDoInCurrentContext:
                    throw NSError(domain: "AudioProcessingError", code: -1)
                @unknown default:
                    throw NSError(domain: "AudioProcessingError", code: -1)
                }
            }

            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 1.0
                completion(.success(outputURL))
            }

        } catch {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.progress = 0
                completion(.failure(error))
                print(error)
            }
        }
    }
}
