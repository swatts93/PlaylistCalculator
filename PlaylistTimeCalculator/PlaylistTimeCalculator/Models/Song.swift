import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var artist: String
    var duration: String // Format: "MM:SS" or "H:MM:SS"
    var isSelected: Bool
    
    init(name: String = "", artist: String = "", duration: String = "", isSelected: Bool = true) {
        self.name = name
        self.artist = artist
        self.duration = duration
        self.isSelected = isSelected
    }
    
    // Convert duration string to seconds
    var durationInSeconds: Int {
        return TimeCalculator.parseTimeToSeconds(duration)
    }
    
    // Check if song has valid duration
    var hasValidDuration: Bool {
        return !duration.isEmpty && durationInSeconds > 0
    }
}

// MARK: - Sample Data
extension Song {
    static let sampleSongs = [
        Song(name: "Bohemian Rhapsody", artist: "Queen", duration: "5:55"),
        Song(name: "Hotel California", artist: "Eagles", duration: "6:30"),
        Song(name: "Stairway to Heaven", artist: "Led Zeppelin", duration: "8:02"),
        Song(name: "Don't Stop Believin'", artist: "Journey", duration: "4:11"),
        Song(name: "Sweet Child O' Mine", artist: "Guns N' Roses", duration: "5:03")
    ]
}