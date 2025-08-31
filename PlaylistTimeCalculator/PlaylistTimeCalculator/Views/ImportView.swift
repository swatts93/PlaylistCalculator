import SwiftUI

struct ImportView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var spotifyClientId = ""
    @State private var selectedPlaylistId = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Spotify Integration Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Import from Spotify")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        if !viewModel.spotifyManager.isAuthenticated {
                            // Not connected state
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Connect to Spotify to import your playlists automatically.")
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Spotify Client ID:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    TextField("Enter your Spotify Client ID", text: $spotifyClientId)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Link("Get this from Spotify Developer Dashboard", destination: URL(string: "https://developer.spotify.com/dashboard")!)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Button(action: {
                                    if !spotifyClientId.isEmpty {
                                        viewModel.connectToSpotify(clientId: spotifyClientId)
                                    }
                                }) {
                                    HStack {
                                        if viewModel.spotifyManager.isLoading {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "link")
                                        }
                                        Text(viewModel.spotifyManager.isLoading ? "Connecting..." : "Connect to Spotify")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(spotifyClientId.isEmpty ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .disabled(spotifyClientId.isEmpty || viewModel.spotifyManager.isLoading)
                            }
                        } else {
                            // Connected state
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Connected to Spotify")
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Select Playlist:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Picker("Select Playlist", selection: $selectedPlaylistId) {
                                        Text("Choose a playlist").tag("")
                                        ForEach(viewModel.spotifyManager.playlists) { playlist in
                                            Text("\(playlist.name) (\(playlist.trackCount) songs)")
                                                .tag(playlist.id)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        if !selectedPlaylistId.isEmpty {
                                            viewModel.importSpotifyPlaylist(selectedPlaylistId)
                                            dismiss()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.down.circle")
                                            Text("Import Selected Playlist")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedPlaylistId.isEmpty ? Color.gray : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    .disabled(selectedPlaylistId.isEmpty)
                                    
                                    Button("Disconnect") {
                                        viewModel.spotifyManager.disconnect()
                                        selectedPlaylistId = ""
                                    }
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Error message
                        if let errorMessage = viewModel.spotifyManager.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    // Manual Import Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Import Playlist Data")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to get your Spotify playlist data:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ImportInstructionRow(
                                    method: "Method 1:",
                                    description: "Visit Chosic.com - No login required!",
                                    url: "https://www.chosic.com/spotify-playlist-exporter/"
                                )
                                
                                ImportInstructionRow(
                                    method: "Method 2:",
                                    description: "Use Exportify.net - Export to CSV",
                                    url: "https://exportify.net/"
                                )
                                
                                Text("**Method 3:** Copy manually from Spotify (format: \"Song Name - Artist MM:SS\")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Paste your playlist data:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $viewModel.importText)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .font(.system(.body, design: .monospaced))
                            
                            if viewModel.importText.isEmpty {
                                Text("Supported formats:\n• CSV: Song Name, Artist, Duration\n• Text: Song Name - Artist MM:SS\n• Tab-separated data\n\nExample:\nBohemian Rhapsody, Queen, 5:55\nHotel California, Eagles, 6:30")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        
                        Button(action: {
                            viewModel.importPlaylistData()
                            dismiss()
                        }) {
                            Text("Import Songs")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.importText.isEmpty ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.importText.isEmpty)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Import Playlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ImportInstructionRow: View {
    let method: String
    let description: String
    let url: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(method)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link(url, destination: URL(string: url)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ImportView(viewModel: PlaylistViewModel())
}