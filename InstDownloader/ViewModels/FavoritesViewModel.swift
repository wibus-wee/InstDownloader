import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteSong] = []
    
    private let favoritesKey = "favoriteSongs"
    
    init() {
        loadFavorites()
    }
    
    func addFavorite(_ song: FavoriteSong) {
        favorites.append(song)
        saveFavorites()
    }
    
    func removeFavorite(_ song: FavoriteSong) {
        favorites.removeAll { $0.id == song.id }
        saveFavorites()
    }
    
    func isFavorite(_ songId: String) -> Bool {
        favorites.contains { $0.songId == songId }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([FavoriteSong].self, from: data) {
            favorites = decoded
        }
    }
}