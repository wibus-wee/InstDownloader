import Foundation

struct FavoriteSong: Identifiable, Codable {
    let id: String
    let name: String
    let source: SongSource
    let uploadTime: Date
    let songId: String
    let songUrl: String?
    
    enum SongSource: String, Codable {
        case zhibeizhe = "指北者"
        case fiveSing = "5Sing"
    }
}
