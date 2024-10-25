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
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var settingsWindowController: NSWindowController?

    var body: some View {
        VStack {
            HStack {
                SearchView(searchText: $searchText, onSearch: performSearch)
                Button(action: { openSettingsWindow() }) {
                    Image(systemName: "gear")
                }
            }

            if zhibeizheViewModel.isSearching {
                ProgressView()
                    .padding()
            } else {
                VStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if zhibeizheViewModel.accompanyList.count > 0 {
                                ForEach(zhibeizheViewModel.accompanyList, id: \.accId) { accompany in
                                    AccompanyRowView(accompany: accompany)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                Text("没有找到伴奏")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(.title3)
                            }
                        }
                    }
                    .frame(height: 500)
                    
                    Spacer(minLength: 16)
                    Divider()
                    Spacer()
                    
                    HStack(spacing: 10){
                        
                        Text("指北者伴奏下载器 © Wibus.")
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
            zhibeizheViewModel.fetchAccompanyList()
        }
        .frame(width: 400, alignment: .leading)
        .animation(.spring(), value: zhibeizheViewModel.accompanyList)
        .padding(16)
        .background(.ultraThinMaterial)
    }

    private func performSearch() {
        isSearching = true
        
        switch settingsViewModel.searchSource {
        case .zhibeizhe:
            zhibeizheViewModel.fetchAccompanyList(name: searchText)
        case .fiveSing:
            print()
        case .both:
            print()
            
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
