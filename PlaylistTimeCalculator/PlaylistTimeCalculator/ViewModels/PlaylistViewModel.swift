import Foundation
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    @Published var songs: [Song] = [Song()] // Start with one empty song
    @Published var startTime: Date?
    @Published var targetEndTime: Date?
    @Published var showingImportSheet = false
    @Published var importText = ""
    @Published var spotifyManager = SpotifyManager()
    
    // MARK: - Computed Properties
    
    var totalDuration: String {
        TimeCalculator.formattedTotalDuration(songs: songs)
    }
    
    var totalDurationInSeconds: Int {
        TimeCalculator.calculateTotalDuration(songs: songs)
    }
    
    var endTimeFromNow: String {
        TimeCalculator.calculateEndTimeFromNow(songs: songs)
    }
    
    var endTimeFromStart: String? {
        guard let startTime = startTime else { return nil }
        return TimeCalculator.calculateEndTime(songs: songs, startTime: startTime)
    }
    
    var timeUntilTarget: String? {
        guard let targetEndTime = targetEndTime else { return nil }
        let seconds = TimeCalculator.timeUntilTarget(targetEndTime)
        return TimeCalculator.secondsToTimeString(seconds)
    }
    
    var timeDifference: (difference: String, playlistTooLong: Bool)? {
        guard let targetEndTime = targetEndTime else { return nil }
        let result = TimeCalculator.calculateTimeDifference(songs: songs, targetTime: targetEndTime)
        return (TimeCalculator.secondsToTimeString(result.difference), result.playlistTooLong)
    }
    
    var averageSongLength: String {
        TimeCalculator.averageSongLength(songs: songs)
    }
    
    var songStats: (total: Int, selected: Int) {
        TimeCalculator.songCountStats(songs: songs)
    }
    
    // MARK: - Song Management
    
    func addSong() {
        songs.append(Song())
    }
    
    func removeSong(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        
        // Ensure we always have at least one song
        if songs.isEmpty {
            songs.append(Song())
        }
    }
    
    func updateSong(_ song: Song, name: String? = nil, artist: String? = nil, duration: String? = nil, isSelected: Bool? = nil) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            if let name = name {
                songs[index].name = name
            }
            if let artist = artist {
                songs[index].artist = artist
            }
            if let duration = duration {
                // Format the duration input
                songs[index].duration = TimeCalculator.formatTimeInput(duration)
            }
            if let isSelected = isSelected {
                songs[index].isSelected = isSelected
            }
        }
    }
    
    func toggleSongSelection(_ song: Song) {
        updateSong(song, isSelected: !song.isSelected)
    }
    
    // MARK: - Import Functionality
    
    func importPlaylistData() {
        let parsedSongs = parseImportedData(importText)
        if !parsedSongs.isEmpty {
            songs = parsedSongs
            importText = ""
            showingImportSheet = false
        }
    }
    
    private func parseImportedData(_ text: String) -> [Song] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var parsedSongs: [Song] = []
        
        for (index, line) in lines.enumerated() {
            var name = ""
            var artist = ""
            var duration = ""
            
            // CSV format detection
            if line.contains(",") {
                let parts = line.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") }
                
                if parts.count >= 3 {
                    name = parts[0]
                    artist = parts[1]
                    // Find duration in format MM:SS or H:MM:SS
                    if let durationMatch = parts.first(where: { TimeCalculator.isValidTimeFormat($0) }) {
                        duration = durationMatch
                    }
                }
            }
            // Tab-separated or dash-separated format
            else if line.contains("\t") || line.contains(" - ") {
                let separator = line.contains("\t") ? "\t" : " - "
                let parts = line.components(separatedBy: separator)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                if parts.count >= 2 {
                    name = parts[0]
                    artist = parts[1]
                    if let durationMatch = parts.first(where: { TimeCalculator.isValidTimeFormat($0) }) {
                        duration = durationMatch
                    }
                }
            }
            // Simple format: extract duration from anywhere
            else {
                let regex = try? NSRegularExpression(pattern: #"\d{1,2}:\d{2}(:\d{2})?"#)
                if let match = regex?.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
                    duration = String(line[Range(match.range, in: line)!])
                    name = line.replacingOccurrences(of: duration, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    name = line
                }
            }
            
            if !name.isEmpty || !duration.isEmpty {
                parsedSongs.append(Song(
                    name: name.isEmpty ? "Song \(index + 1)" : name,
                    artist: artist.isEmpty ? "Unknown Artist" : artist,
                    duration: duration,
                    isSelected: true
                ))
            }
        }
        
        return parsedSongs
    }
    
    // MARK: - Spotify Integration
    
    func connectToSpotify(clientId: String) {
        Task {
            await spotifyManager.authenticate(clientId: clientId)
        }
    }
    
    func importSpotifyPlaylist(_ playlistId: String) {
        Task {
            let tracks = await spotifyManager.getPlaylistTracks(playlistId: playlistId)
            let importedSongs = tracks.map { track in
                Song(
                    name: track.name,
                    artist: track.artist,
                    duration: TimeCalculator.secondsToTimeString(track.durationMs / 1000),
                    isSelected: true
                )
            }
            
            if !importedSongs.isEmpty {
                songs = importedSongs
            }
        }
    }
    
    // MARK: - Time Settings
    
    func setStartTime(_ time: Date?) {
        startTime = time
    }
    
    func setTargetEndTime(_ time: Date?) {
        targetEndTime = time
    }
    
    // MARK: - Validation
    
    var hasValidSongs: Bool {
        songs.contains { $0.isSelected && $0.hasValidDuration }
    }
    
    var selectedSongsCount: Int {
        songs.filter { $0.isSelected }.count
    }
}