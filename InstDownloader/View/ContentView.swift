//
//  ContentView.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/20.
//

import SwiftUI
import AppKit

let url = "http://xp.yuepuvip.com:8100/one/accompany/list"

struct ContentView: View {
    @StateObject private var zhibeizheViewModel = AccompanyListViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var fiveSingViewModel = FiveSingService()
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var settingsWindowController: NSWindowController?
    @State private var currentPage = 1
    @State private var itemsPerPage = 20
    
    var body: some View {
        VStack {
            HStack {
                SearchView(searchText: $searchText, onSearch: performSearch)
                Button(action: { openSettingsWindow() }) {
                    Image(systemName: "gear")
                }
            }

            if zhibeizheViewModel.isSearching || fiveSingViewModel.isSearching {
                ProgressView()
                    .padding()
            } else {
                VStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            switch settingsViewModel.searchSource {
                            case .zhibeizhe:
                                if zhibeizheViewModel.accompanyList.isEmpty {
                                    Text("没有找到伴奏")
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(.title3)
                                } else {
                                    ForEach(zhibeizheViewModel.accompanyList, id: \.accId) { accompany in
                                        AccompanyRowView(accompany: accompany)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            case .fiveSing:
                                if fiveSingViewModel.searchResults.isEmpty {
                                    Text("没有找到歌曲")
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(.title3)
                                } else {
                                    ForEach(fiveSingViewModel.searchResults, id: \.songId) { song in
                                        FiveSingRowView(song: song)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 500)
                    
                    HStack {
                        Button("上一页") {
                            goToPreviousPage()
                        }
                        .disabled(currentPage == 1 || isSearching)

                        Text("第 \(currentPage) 页")

                        Button("下一页") {
                            goToNextPage()
                        }
                        .disabled(isSearching || 
                            (settingsViewModel.searchSource == .zhibeizhe && !zhibeizheViewModel.hasMorePages) ||
                            (settingsViewModel.searchSource == .fiveSing && !fiveSingViewModel.hasMorePages))
                    }
                    .padding()
                    
                    Spacer(minLength: 16)
                    Divider()
                    Spacer()
                    
                    HStack(spacing: 10){
                        
                        Text("InstDownloader © Wibus.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("于 2024 年 10 月 20 日发布")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("伴奏下载器")
        .onAppear {
            performSearch()
        }
        .frame(width: 400, alignment: .leading)
        .animation(.spring(), value: zhibeizheViewModel.accompanyList)
        .padding(16)
        .background(.ultraThinMaterial)
        .onChange(of: settingsViewModel.searchSource) { oldValue, newValue in
            currentPage = 1
            performSearch()
        }
    }

    private func performSearch() {
        isSearching = true
        
        Task {
            do {
                switch settingsViewModel.searchSource {
                case .zhibeizhe:
                    await zhibeizheViewModel.fetchAccompanyList(name: searchText, page: currentPage, limit: itemsPerPage)
                case .fiveSing:
                    try await fiveSingViewModel.searchSongs(keyword: searchText, page: String(currentPage))
                }
            } catch {
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.alertStyle = .critical
                    alert.messageText = "搜索错误: \(errorMessage)"
                    alert.runModal()
                }
                print("搜索错误: \(error)")
            }
            
            DispatchQueue.main.async {
                isSearching = false
            }
        }
    }

    private func goToNextPage() {
        currentPage += 1
        performSearch()
    }

    private func goToPreviousPage() {
        if currentPage > 1 {
            currentPage -= 1
            performSearch()
        }
    }

    private func openSettingsWindow() {
        if let windowController = settingsWindowController {
            windowController.showWindow(nil)
        } else {
            let settingsWindow = NSWindow(
                contentRect: NSRect(x: 200, y: 200, width: 300, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow.titleVisibility = .hidden
            settingsWindow.titlebarAppearsTransparent = true
            settingsWindow.backgroundColor = .clear
            settingsWindow.styleMask.insert(.fullSizeContentView)
            settingsWindow.standardWindowButton(.closeButton)?.isHidden = false
            settingsWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
            settingsWindow.standardWindowButton(.zoomButton)?.isHidden = true
            let settingsView = SettingsView(viewModel: settingsViewModel)
            settingsWindow.contentView = NSHostingView(rootView: settingsView)
            
            let windowController = NSWindowController(window: settingsWindow)
            settingsWindowController = windowController
            
            windowController.showWindow(nil)
        }
    }
}
