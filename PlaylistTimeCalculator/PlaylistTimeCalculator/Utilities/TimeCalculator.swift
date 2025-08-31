import Foundation

class TimeCalculator {
    
    // MARK: - Time Parsing
    
    /// Parse time string (MM:SS or H:MM:SS) to seconds
    static func parseTimeToSeconds(_ timeStr: String) -> Int {
        guard !timeStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return 0 }
        
        let parts = timeStr.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":")
            .compactMap { Int($0) }
        
        switch parts.count {
        case 2: // MM:SS format
            return parts[0] * 60 + parts[1]
        case 3: // H:MM:SS format
            return parts[0] * 3600 + parts[1] * 60 + parts[2]
        default:
            return 0
        }
    }
    
    /// Convert seconds to time string (MM:SS or H:MM:SS)
    static func secondsToTimeString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    // MARK: - Playlist Calculations
    
    /// Calculate total duration of selected songs
    static func calculateTotalDuration(songs: [Song]) -> Int {
        return songs
            .filter { $0.isSelected }
            .reduce(0) { $0 + $1.durationInSeconds }
    }
    
    /// Get formatted total duration string
    static func formattedTotalDuration(songs: [Song]) -> String {
        let totalSeconds = calculateTotalDuration(songs: songs)
        return secondsToTimeString(totalSeconds)
    }
    
    // MARK: - End Time Calculations
    
    /// Calculate when playlist will end from now
    static func calculateEndTimeFromNow(songs: [Song]) -> String {
        let totalSeconds = calculateTotalDuration(songs: songs)
        let endTime = Date().addingTimeInterval(TimeInterval(totalSeconds))
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    /// Calculate when playlist will end from a specific start time
    static func calculateEndTime(songs: [Song], startTime: Date) -> String {
        let totalSeconds = calculateTotalDuration(songs: songs)
        let endTime = startTime.addingTimeInterval(TimeInterval(totalSeconds))
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    // MARK: - Target Time Calculations
    
    /// Calculate time until target from now
    static func timeUntilTarget(_ targetTime: Date) -> Int {
        let now = Date()
        var target = targetTime
        
        // If target time is earlier than now, assume it's tomorrow
        if target < now {
            target = Calendar.current.date(byAdding: .day, value: 1, to: target) ?? target
        }
        
        return Int(target.timeIntervalSince(now))
    }
    
    /// Calculate difference between playlist duration and target time
    static func calculateTimeDifference(songs: [Song], targetTime: Date) -> (difference: Int, playlistTooLong: Bool) {
        let playlistDuration = calculateTotalDuration(songs: songs)
        let timeUntilTarget = timeUntilTarget(targetTime)
        let difference = abs(timeUntilTarget - playlistDuration)
        let playlistTooLong = playlistDuration > timeUntilTarget
        
        return (difference, playlistTooLong)
    }
    
    // MARK: - Statistics
    
    /// Calculate average song length for selected songs with duration
    static func averageSongLength(songs: [Song]) -> String {
        let validSongs = songs.filter { $0.isSelected && $0.hasValidDuration }
        guard !validSongs.isEmpty else { return "0:00" }
        
        let totalDuration = validSongs.reduce(0) { $0 + $1.durationInSeconds }
        let average = totalDuration / validSongs.count
        return secondsToTimeString(average)
    }
    
    /// Get song count statistics
    static func songCountStats(songs: [Song]) -> (total: Int, selected: Int) {
        let total = songs.count
        let selected = songs.filter { $0.isSelected }.count
        return (total, selected)
    }
    
    // MARK: - Time Parsing Utilities
    
    /// Validate time format (MM:SS or H:MM:SS)
    static func isValidTimeFormat(_ timeString: String) -> Bool {
        let pattern = #"^\d{1,2}:\d{2}(:\d{2})?$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: timeString.utf16.count)
        return regex?.firstMatch(in: timeString, options: [], range: range) != nil
    }
    
    /// Clean and format time input
    static func formatTimeInput(_ input: String) -> String {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidTimeFormat(cleaned) else { return input }
        
        let seconds = parseTimeToSeconds(cleaned)
        return secondsToTimeString(seconds)
    }
}