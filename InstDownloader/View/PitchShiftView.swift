//
//  PitchShiftView.swift
//  InstDownloader
//
//  Created by wibus-wee on 2024/11/02.
//

import AVFoundation
import SwiftUI

struct PitchShiftView: View {
    @StateObject private var pitchShifter = AudioPitchShifter()
    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var audioURL: URL?
    @State private var originalPitch: Pitch = .C
    @State private var targetPitch: Pitch = .C
    @State private var shiftDirection: ShiftDirection = .auto
    @State private var isDragging = false
    @State private var semitonesDiff: Int = 0

    enum Pitch: String, CaseIterable {
        case C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B

        var displayName: String {
            switch self {
            case .Db: return "C#/Db"
            case .Eb: return "D#/Eb"
            case .Gb: return "F#/Gb"
            case .Ab: return "G#/Ab"
            case .Bb: return "A#/Bb"
            default: return rawValue
            }
        }
    }

    enum ShiftDirection: String, CaseIterable {
        case up = "向上"
        case down = "向下"
        case auto = "自动"
    }

    var body: some View {
        VStack {
            VStack(spacing: 25) {
                // 拖拽区域
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(width: 200, height: 100)
                        .foregroundColor(isDragging ? .blue : .gray)

                    HStack(spacing: 10) {
                        Image(systemName: "music.note")
                            .resizable()
                            .frame(width: 30, height: 30)

                        if let url = audioURL {
                            Text(url.lastPathComponent)
                                .truncationMode(.middle)
                                .frame(maxWidth: 100)
                        } else {
                            Text("拖拽音频文件到这里")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                    guard let provider = providers.first else { return false }

                    let supportedTypes = ["mp3", "wav", "m4a", "aac"]

                    provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, _ in
                        DispatchQueue.main.async {
                            if let data = data,
                               let path = String(data: data, encoding: .utf8),
                               let url = URL(string: path)
                            {
                                let fileExtension = url.pathExtension.lowercased()
                                if supportedTypes.contains(fileExtension) {
                                    self.audioURL = URL(filePath: url.path)

                                    // 从文件名中识别音调
                                    let filename = url.lastPathComponent.uppercased()
                                    for pitch in Pitch.allCases {
                                        // 检查文件名中是否包含 "X调" 或 "KEY OF X" 的模式
                                        if filename.contains("\(pitch.rawValue)调") ||
                                            filename.contains("\(pitch.rawValue) 调")
                                        {
                                            // 他文件名有可能是：降B调，升B调，那这样就会出现问题了
                                            if filename.contains("降") || filename.contains("升") {
                                                // 如果文件名包含降或升，则将音调设置为当前识别到的音调的降或升
                                                if filename.contains("降") {
                                                    self.originalPitch = Pitch(rawValue: "\(pitch.rawValue)b")!
                                                } else {
                                                    self.originalPitch = Pitch(rawValue: "\(pitch.rawValue)#")!
                                                }
                                            } else {
                                                self.originalPitch = pitch
                                            }
                                            break
                                        }

                                        switch pitch {
                                        case .Db where filename.contains("C#"):
                                            self.originalPitch = .Db
                                        case .Eb where filename.contains("D#"):
                                            self.originalPitch = .Eb
                                        case .Gb where filename.contains("F#"):
                                            self.originalPitch = .Gb
                                        case .Ab where filename.contains("G#"):
                                            self.originalPitch = .Ab
                                        case .Bb where filename.contains("A#"):
                                            self.originalPitch = .Bb
                                        default: break
                                        }
                                    }
                                } else {
                                    alertMessage = "不支持的文件格式。请使用 MP3、WAV、M4A 或 AAC 格式的音频文件。"
                                    showAlert = true
                                }
                            }
                        }
                    }
                    return true
                }

                Divider()

                // 音调选择
                HStack {
                    // Text("原调:")
                    Picker("原调", selection: $originalPitch) {
                        ForEach(Pitch.allCases, id: \.self) { pitch in
                            Text(pitch.displayName).tag(pitch)
                        }
                    }
                    .onChange(of: originalPitch) { _ in
                        calculateSemitones()
                    }
                }

                HStack {
                    // Text("目标调:")
                    Picker("目标调", selection: $targetPitch) {
                        ForEach(Pitch.allCases, id: \.self) { pitch in
                            Text(pitch.displayName).tag(pitch)
                        }
                    }
                    .onChange(of: targetPitch) { _ in
                        calculateSemitones()
                    }
                }

                // 转调方向
                HStack {
                    // Text("转调方向:")
                    Picker("转调方向", selection: $shiftDirection) {
                        ForEach(ShiftDirection.allCases, id: \.self) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    .onChange(of: shiftDirection) { _ in
                        calculateSemitones()
                    }
                }

                // 显示转调信息
                if semitonesDiff != 0 {
                    VStack(alignment: .leading) {
                      Text("需要将音频\(semitonesDiff > 0 ? "升高" : "降低") \(abs(semitonesDiff)) 个半音")
                    }
                    .padding()
                    .foregroundColor(.secondary)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }

                if pitchShifter.isProcessing {
                    VStack {
                        ProgressView(value: pitchShifter.progress)
                        Text("\(Int(pitchShifter.progress * 100))%")
                    }
                }

                Button(action: processAudio) {
                    Text("开始转调")
                        .frame(width: 100)
                        .foregroundColor(.white)
                }
                .disabled(audioURL == nil || semitonesDiff == 0 || pitchShifter.isProcessing)

                Spacer()
            }
        }
        .padding()
        .background(.regularMaterial)
        .frame(width: 350, height: 450)
        .enableInjection()
        .alert("处理结果", isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func processAudio() {
        guard let inputURL = audioURL else { return }

        pitchShifter.shiftPitch(inputURL: inputURL, semitones: semitonesDiff) { result in
            switch result {
            case let .success(outputURL):
                // 创建保存面板
                let savePanel = NSSavePanel()
                savePanel.allowedContentTypes = [.audio]
                savePanel.nameFieldStringValue = "转调后的音频.m4a"

                savePanel.begin { response in
                    if response == .OK, let saveURL = savePanel.url {
                        do {
                            if FileManager.default.fileExists(atPath: saveURL.path) {
                                try FileManager.default.removeItem(at: saveURL)
                            }
                            try FileManager.default.moveItem(at: outputURL, to: saveURL)
                            alertMessage = "转调成功！文件已保存至: \(saveURL.path)"
                        } catch {
                            alertMessage = "保存文件失败: \(error.localizedDescription)"
                        }
                    } else {
                        // 清理临时文件
                        try? FileManager.default.removeItem(at: outputURL)
                        alertMessage = "取消保存"
                    }
                    showAlert = true
                }

            case let .failure(error):
                alertMessage = "转调失败: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    #if DEBUG
        @ObserveInjection var forceRedraw
    #endif

    private func calculateSemitones() {
        let pitches = Pitch.allCases
        guard let originalIndex = pitches.firstIndex(of: originalPitch),
              let targetIndex = pitches.firstIndex(of: targetPitch)
        else {
            return
        }

        var diff = targetIndex - originalIndex

        // 处理跨越八度的情况
        if diff > 6 {
            diff -= 12
        } else if diff < -6 {
            diff += 12
        }

        switch shiftDirection {
        case .up:
            semitonesDiff = diff >= 0 ? diff : diff + 12
        case .down:
            semitonesDiff = diff <= 0 ? diff : diff - 12
        case .auto:
            semitonesDiff = diff
        }
    }
}
