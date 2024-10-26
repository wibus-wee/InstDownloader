//
//  SettingsView.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/25.
//

import SwiftUI

enum SearchSource: String, CaseIterable {
    case zhibeizhe = "指北者"
    case fiveSing = "5Sing"
}

class SettingsViewModel: ObservableObject {
    @Published var searchSource: SearchSource {
        didSet {
            UserDefaults.standard.set(searchSource.rawValue, forKey: "searchSource")
        }
    }

    init() {
        let savedSource = UserDefaults.standard.string(forKey: "searchSource") ?? SearchSource.zhibeizhe.rawValue
        self.searchSource = SearchSource(rawValue: savedSource) ?? .zhibeizhe
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("设置")
                        .font(.title2)
                        .bold()

                    Text("设置InstDownloader的行为")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("设置选项")
                        .font(.title3)
                        .bold()

                    Form {
                        VStack(alignment: .leading) {
                            Picker("搜索来源", selection: $viewModel.searchSource) {
                                ForEach(SearchSource.allCases, id: \.self) { source in
                                    Text(source.rawValue).tag(source)
                                }
                            }

                            Text("选择搜索结果的来源，选择不同来源会影响搜索结果的呈现")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("不同来源的区别：")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("指北者 - 搜索较慢，曲库质量尚可")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("5Sing - 搜索较快，曲库质量混杂")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()

                Spacer(minLength: 16)
                VStack {
                    Divider()
                        .padding()
                    
                    HStack(spacing: 10) {
                        Text("InstDownloader © Wibus.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("于 2024 年 10 月 20 日发布")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()

            }
        }
        .frame(width: 350, height: 300)
        .background(.ultraThinMaterial)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}
