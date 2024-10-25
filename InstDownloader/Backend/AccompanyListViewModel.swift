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
    
    func fetchAccompanyList(name: String = "") {
        isSearching = true
        let params: [String: Any] = [
            "type": "accompany",
            "offset": 1,
            "limit": 20,
            "accNames": name,
            "versionNo": 1
        ]
        
        let request = URLRequest.createRequest(url: ZhibeizheAPI.GET_ACCOMPANY_LIST, query: params)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isSearching = false
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        decoder.dateDecodingStrategy = .formatted(dateFormatter)
                        
                        let apiResponse = try decoder.decode(APIResponse.self, from: data)
                        self.accompanyList = apiResponse.rows
                    } catch {
                        print("解码错误: \(error)")
                    }
                } else if let error = error {
                    print("网络请求错误: \(error)")
                }
            }
        }.resume()
    }
}
