//
//  ZhibeizheVideo.swift
//  InstDownloader
//
//  Created by wibus on 2024/11/2.
//

import Foundation

// 请求参数
struct IGetDynamicSpecList: Codable {
    let type: String
    let offset: Int
    let limit: Int
    let specNames: String
    let versionNo: Int
    
    enum CodingKeys: String, CodingKey {
        case type, offset, limit, specNames, versionNo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        guard type == "dynaVideo" else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "类型必须是'dynaVideo'")
        }
        offset = try container.decode(Int.self, forKey: .offset)
        limit = try container.decode(Int.self, forKey: .limit)
        specNames = try container.decode(String.self, forKey: .specNames)
        versionNo = try container.decode(Int.self, forKey: .versionNo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("dynaVideo", forKey: .type)
        try container.encode(offset, forKey: .offset)
        try container.encode(limit, forKey: .limit)
        try container.encode(specNames, forKey: .specNames)
        try container.encode(versionNo, forKey: .versionNo)
    }
}

// 响应数据
struct DynamicSpecListResponse: Codable {
    let total: Int
    let rows: [DynamicSpecListRow]
}

struct DynamicSpecListRow: Codable, Identifiable, Equatable {
    let specId: String
    let specTune: String
    let specTuneName: String
    let specMusical: String
    let specMusicalName: String
    let specName: String
    let specUrl: String
    let noSpecUrl: String
    let uploaderTime: String
    let uploader: String
    let uploaderName: String
    let commNum: String
    let collectNum: String
    let giveNum: String
    let downloadNum: String
    let specStatus: String?
    let specStatusName: String?
    let isSet: String?
    let category: String
    let categoryName: String
    let playNum: Int
    let copyrightType: String?
    let bId: String?
    let shakeLight: String?
    let degreePoint: String?
    let afStatus: String?
    let fileStyle: String?
    let fileStyleName: String?
    let isSong: String?
    let categoryItem: String?
    let customClassify: String?
    let jobState: String?
    let trackList: [TrackListItem]?
    let isPay: String?
    let price: Int?
    let wordWriter: String?
    let songWriter: String?
    
    var id: String { specId }

    static func == (lhs: DynamicSpecListRow, rhs: DynamicSpecListRow) -> Bool {
        lhs.specId == rhs.specId
    }
}

struct TrackListItem: Codable {
    let rownum: Int
    let typeName: String
}