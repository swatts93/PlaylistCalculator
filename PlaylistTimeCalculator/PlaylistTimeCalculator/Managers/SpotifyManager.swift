import Foundation
import SwiftUI

struct SpotifyTrack {
    let name: String
    let artist: String
    let durationMs: Int
}

struct SpotifyPlaylist: Identifiable {
    let id: String
    let name: String
    let trackCount: Int
}

@MainActor
class SpotifyManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var playlists: [SpotifyPlaylist] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var accessToken: String?
    private var clientId: String?
    
    private let redirectURI = "playlist-timer://callback"
    private let scopes = "playlist-read-private playlist-read-collaborative"
    
    // MARK: - Authentication
    
    func authenticate(clientId: String) async {
        self.clientId = clientId
        
        // For demo purposes, we'll simulate authentication
        // In a real app, you'd implement OAuth 2.0 flow
        isLoading = true
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Simulate successful authentication with demo data
            isAuthenticated = true
            accessToken = "demo_access_token"
            
            // Load demo playlists
            playlists = [
                SpotifyPlaylist(id: "demo1", name: "Chill Vibes", trackCount: 25),
                SpotifyPlaylist(id: "demo2", name: "Workout Hits", trackCount: 30),
                SpotifyPlaylist(id: "demo3", name: "Road Trip Mix", trackCount: 45),
                SpotifyPlaylist(id: "demo4", name: "Focus Music", trackCount: 20),
                SpotifyPlaylist(id: "demo5", name: "Party Favorites", trackCount: 35)
            ]
            
            errorMessage = nil
        } catch {
            errorMessage = "Failed to connect to Spotify: \(error.localizedDescription)"
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func disconnect() {
        isAuthenticated = false
        accessToken = nil
        clientId = nil
        playlists = []
        errorMessage = nil
    }
    
    // MARK: - Playlist Operations
    
    func getPlaylistTracks(playlistId: String) async -> [SpotifyTrack] {
        guard isAuthenticated else { return [] }
        
        isLoading = true
        defer { isLoading = false }
        
        // Demo track data for different playlists
        let demoTracks: [String: [SpotifyTrack]] = [
            "demo1": [
                SpotifyTrack(name: "Weightless", artist: "Marconi Union", durationMs: 485000),
                SpotifyTrack(name: "Aqueous Transmission", artist: "Incubus", durationMs: 443000),
                SpotifyTrack(name: "Mellomaniac", artist: "DJ Shah", durationMs: 521000),
                SpotifyTrack(name: "Watermark", artist: "Enya", durationMs: 343000),
                SpotifyTrack(name: "Strawberry Swing", artist: "Coldplay", durationMs: 256000)
            ],
            "demo2": [
                SpotifyTrack(name: "Eye of the Tiger", artist: "Survivor", durationMs: 246000),
                SpotifyTrack(name: "Stronger", artist: "Kelly Clarkson", durationMs: 222000),
                SpotifyTrack(name: "Can't Hold Us", artist: "Macklemore & Ryan Lewis", durationMs: 258000),
                SpotifyTrack(name: "Titanium", artist: "David Guetta ft. Sia", durationMs: 245000),
                SpotifyTrack(name: "Pump It", artist: "The Black Eyed Peas", durationMs: 213000)
            ],
            "demo3": [
                SpotifyTrack(name: "Life is a Highway", artist: "Tom Cochrane", durationMs: 275000),
                SpotifyTrack(name: "Don't Stop Me Now", artist: "Queen", durationMs: 209000),
                SpotifyTrack(name: "Mr. Blue Sky", artist: "Electric Light Orchestra", durationMs: 303000),
                SpotifyTrack(name: "Sweet Caroline", artist: "Neil Diamond", durationMs: 201000),
                SpotifyTrack(name: "Journey - Don't Stop Believin'", artist: "Journey", durationMs: 251000)
            ],
            "demo4": [
                SpotifyTrack(name: "Ludovico Einaudi - Nuvole Bianche", artist: "Ludovico Einaudi", durationMs: 344000),
                SpotifyTrack(name: "Max Richter - On The Nature Of Daylight", artist: "Max Richter", durationMs: 385000),
                SpotifyTrack(name: "Ólafur Arnalds - Near Light", artist: "Ólafur Arnalds", durationMs: 267000),
                SpotifyTrack(name: "Nils Frahm - Says", artist: "Nils Frahm", durationMs: 391000)
            ],
            "demo5": [
                SpotifyTrack(name: "Uptown Funk", artist: "Mark Ronson ft. Bruno Mars", durationMs: 270000),
                SpotifyTrack(name: "Can't Stop the Feeling!", artist: "Justin Timberlake", durationMs: 236000),
                SpotifyTrack(name: "Happy", artist: "Pharrell Williams", durationMs: 232000),
                SpotifyTrack(name: "Good as Hell", artist: "Lizzo", durationMs: 219000),
                SpotifyTrack(name: "Shut Up and Dance", artist: "Walk the Moon", durationMs: 197000)
            ]
        ]
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return demoTracks[playlistId] ?? []
    }
    
    // MARK: - Real Spotify Integration (for production)
    
    /*
    // This is how you would implement real Spotify integration:
    
    private func exchangeCodeForToken(_ code: String) async throws {
        guard let clientId = clientId else { throw SpotifyError.missingClientId }
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURI)&client_id=\(clientId)&client_secret=YOUR_CLIENT_SECRET"
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        accessToken = tokenResponse.access_token
        isAuthenticated = true
    }
    
    private func fetchUserPlaylists() async throws -> [SpotifyPlaylist] {
        guard let accessToken = accessToken else { throw SpotifyError.notAuthenticated }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/playlists?limit=50")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: data)
        
        return playlistResponse.items.map { playlist in
            SpotifyPlaylist(
                id: playlist.id,
                name: playlist.name,
                trackCount: playlist.tracks.total
            )
        }
    }
    */
}

// MARK: - Error Types

enum SpotifyError: LocalizedError {
    case missingClientId
    case notAuthenticated
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingClientId:
            return "Spotify Client ID is required"
        case .notAuthenticated:
            return "Not authenticated with Spotify"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}