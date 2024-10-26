//
//  AccompanyListViewModel.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/24.
//

import SwiftUI

class AccompanyListViewModel: ObservableObject {
    @Published var accompanyList: [AccompanyListRow] = []
    @Published var isSearching = false
    @Published var hasMorePages = true
    @Published var totalItems = 0
    
    func fetchAccompanyList(name: String = "", page: Int = 1, limit: Int = 20) async {
        DispatchQueue.main.async {
            self.isSearching = true
        }
        let params: [String: Any] = [
            "type": "accompany",
            "offset": (page - 1) * limit + 1,
            "limit": limit,
            "accNames": name,
            "versionNo": 1
        ]
        
        let request = URLRequest.createRequest(url: ZhibeizheAPI.GET_ACCOMPANY_LIST, query: params)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let apiResponse = try decoder.decode(APIResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.accompanyList = apiResponse.rows
                self.totalItems = apiResponse.total
                self.hasMorePages = self.accompanyList.count < self.totalItems
                self.isSearching = false
            }
        } catch {
            print("网络请求错误: \(error)")
            DispatchQueue.main.async {
                self.isSearching = false
            }
        }
    }
}
