import Foundation

// FiveSing过滤类型枚举
enum FiveSingFilterType: Int, Codable {
    case all = 0
    case originalSong = 1
    case singSong = 10
    case byLyric = 11
    case byMelody = 12
    case byPostProcessed = 13
    case byArrangement = 14
    case instrumental = 3
}

// 搜索结果结构体
struct FiveSingSearchResult: Codable {
    let type: Int
    var list: [SongInfo]
    let pageInfo: PageInfo
    
    struct SongInfo: Codable, Identifiable, Equatable {
        let createTime: String
        let originSinger: String
        var songName: String
        let status: Int
        let collectCnt: Int
        let style: String
        let downloadCnt: Int
        let playCnt: Int
        let singer: String
        let postProduction: String
        let popularityCnt: Int
        let songWriter: String
        let composer: String
        let songId: Int
        let optComposer: String
        let ext: String
        let songSize: Int
        let nickName: String
        let singerId: Int
        let type: Int
        let typeName: String
        let typeEname: String
        let songurl: String
        let downloadurl: String
        
        var id: Int { songId }

        static func == (lhs: SongInfo, rhs: SongInfo) -> Bool {
            lhs.songId == rhs.songId
        }
    }
    
    struct PageInfo: Codable {
        let cur: Int
        let totalCount: Int
        let totalPages: Int
    }
}

// 单曲结果结构体
struct FiveSingSongResult: Codable {
    let msg: String
    let code: Int
    let data: SongData
    let success: Bool
    let message: String
    
    struct SongData: Codable {
        let songid: Int
        let songtype: String
        let squrl: String
        let squrl_backup: String
        let squrlmd5: String
        let sqsize: String
        let sqext: String
        let hqurl: String
        let hqurl_backup: String
        let hqurlmd5: String
        let hqsize: String
        let hqext: String
        let lqurl: String
        let lqurl_backup: String
        let lqurlmd5: String
        let lqsize: String
        let lqext: String
        let songName: String
        let songKind: Int
        let user: User
        let DigitalAlbumID: Int
        
        struct User: Codable {
            let ID: Int
            let NN: String
            let I: String
        }
    }
}
