import Foundation
import CryptoKit

class FiveSingService: ObservableObject {
    @Published var searchResults: [FiveSingSearchResult.SongInfo] = []
    @Published var isSearching = false
    @Published var hasMorePages = true
    @Published var totalItems = 0
    
    private let baseSearchURL = "http://search.5sing.kugou.com"
    private let baseSongURL = "https://5sservice.kugou.com"
    
    func searchSongs(keyword: String, page: String = "1", filter: String = "0", type: String = "0") async throws {
        DispatchQueue.main.async {
            self.isSearching = true
        }
        let url = "\(baseSearchURL)/home/json"
        let parameters: [String: Any] = [
            "keyword": keyword.count > 0 ? keyword : "热门",
            "sort": 1,
            "page": page,
            "filter": filter,
            "type": type
        ]
        
        let request = URLRequest.createRequest(url: url, query: parameters)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        var result = try JSONDecoder().decode(FiveSingSearchResult.self, from: data)
        
        // 去掉HTML标签
        result.list = result.list.map { song in
            var modifiedSong = song
            modifiedSong.songName = modifiedSong.songName.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            return modifiedSong
        }

        DispatchQueue.main.async {
            self.searchResults = result.list
            self.totalItems = result.pageInfo.totalCount
            self.hasMorePages = self.searchResults.count < self.totalItems
            self.isSearching = false
        }
    }
    
    func song(songid: String) async throws -> FiveSingSongResult {
        let appKey = "5uytoxQewcvIc1gn1PlNF0T2jbbOzRl"
        let appid = 2918
        let clientver = 1000
        let songtype = "bz"
        
        let mid = UUID().uuidString.md5
        let clienttime = Int(Date().timeIntervalSince1970 * 1000)
        let uuid = mid
        let dfid = "-"
        
        var params: [String: Any] = [
            "appid": appid,
            "clientver": clientver,
            "mid": mid,
            "uuid": uuid,
            "dfid": dfid,
            "songid": songid,
            "songtype": songtype,
            "clienttime": clienttime
        ]
        
        // 生成签名
        let sortedKeys = params.keys.sorted()
        var signatureInput = appKey
        for key in sortedKeys {
            signatureInput += "\(key)=\(params[key]!)"
        }
        signatureInput += appKey
        
        let signature = signatureInput.md5
        params["signature"] = signature
        
        let url = "\(baseSongURL)/song/getsongurl"
        let request = URLRequest.createRequest(url: url, query: params)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(FiveSingSongResult.self, from: data)
        
        return result
    }
}

extension String {
    var md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
