//
//  Zhibeizhe.swift
//  InstDownloader
//
//  Created by wibus on 2024/10/24.
//

import Foundation


// 请求参数
struct IGetAccompanyList: Codable {
    let type: String
    let offset: Int
    let limit: Int
    let accNames: String
    let versionNo: Int
    
    enum CodingKeys: String, CodingKey {
        case type, offset, limit, accNames, versionNo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        guard type == "accompany" else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "类型必须是'accompany'")
        }
        offset = try container.decode(Int.self, forKey: .offset)
        limit = try container.decode(Int.self, forKey: .limit)
        accNames = try container.decode(String.self, forKey: .accNames)
        versionNo = try container.decode(Int.self, forKey: .versionNo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("accompany", forKey: .type)
        try container.encode(offset, forKey: .offset)
        try container.encode(limit, forKey: .limit)
        try container.encode(accNames, forKey: .accNames)
        try container.encode(versionNo, forKey: .versionNo)
    }
}

// 响应数据
struct APIResponse: Codable {
    let total: Int
    let rows: [AccompanyListRow]
}

struct AccompanyListRow: Codable, Identifiable, Equatable {
    let accId: String
    let accName: String
    let classifyId: String?
    let classifyName: String?
    let accFileUrl: String
    let accUserId: String
    let accUserName: String
    let accTime: Date
    let isSold: String?
    let downloadNum: String
    let collectNum: String
    let hostNum: String
    let state: Int
    let playNum: Int
    let copyrightType: String?
    let accType: String
    let categoryItemName: String?
    let preId: String
    let nextId: String
    let isColl: String?
    let accStatus: String
    let isPriority: String?
    let fileUrl: String
    let accEncryUrl: String?
    let isShow: String?
    let accAuthor: String?
    let accImg: String?
    let bId: String?
    let category: String?
    let categoryName: String?
    let isEncry: String?
    let customClassify: String?
    let fileStyle: String?
    let fileStyleName: String?
    let categoryItem: String?
    
    enum CodingKeys: String, CodingKey {
        case accId, accName, classifyId, classifyName, accFileUrl, accUserId, accUserName, accTime, isSold, downloadNum, collectNum, hostNum, state, playNum, copyrightType, accType, categoryItemName, preId, nextId, isColl, accStatus, isPriority, fileUrl, accEncryUrl, isShow, accAuthor, accImg, bId, category, categoryName, isEncry, customClassify, fileStyle, fileStyleName, categoryItem
    }

    var id: String { accId }

    static func == (lhs: AccompanyListRow, rhs: AccompanyListRow) -> Bool {
        lhs.accId == rhs.accId
    }
}

enum ZhibeizheAPI {
    static let BASE_URL = "http://xp.yuepuvip.com:8100/one"
    static let GET_ACCOMPANY_LIST = "\(BASE_URL)/accompany/list"
    static let GET_DYNAMIC_SPEC_LIST = "\(BASE_URL)/dynamicspec/list"
}

extension URLRequest {
    static func createRequest(url: String, query: [String: Any]) -> URLRequest {
        var components = URLComponents(string: url)!
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        #if DEBUG
            print("请求URL: \(components.url?.absoluteString ?? "未知")")
        #endif
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        return request
    }
}
