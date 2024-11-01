//
//  ZhibeizheVideoListViewModel.swift
//  InstDownloader
//
//  Created by wibus on 2024/11/2.
//

// VideoListViewModel.swift

import SwiftUI

class ZhibeizheVideoListViewModel: ObservableObject {
    @Published var videoList: [DynamicSpecListRow] = []
    @Published var isSearching = false
    @Published var hasMorePages = true
    @Published var totalItems = 0
    
    func fetchVideoList(name: String = "", page: Int = 1, limit: Int = 20) async {
        DispatchQueue.main.async {
            self.isSearching = true
        }
        
        let params: [String: Any] = [
            "type": "dynaVideo",
            "offset": (page - 1) * limit + 1,
            "limit": limit,
            "specNames": name,
            "versionNo": 21
        ]
        
        let request = URLRequest.createRequest(url: ZhibeizheAPI.GET_DYNAMIC_SPEC_LIST, query: params)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(DynamicSpecListResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.videoList = apiResponse.rows
                self.totalItems = apiResponse.total
                self.hasMorePages = self.videoList.count < self.totalItems
                self.isSearching = false
            }
        } catch {
            print("视频列表请求错误: \(error)")
            DispatchQueue.main.async {
                self.isSearching = false
            }
        }
    }
}