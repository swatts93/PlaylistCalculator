import SwiftUI

struct SongRowView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    let song: Song
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: {
                viewModel.toggleSongSelection(song)
            }) {
                Image(systemName: song.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(song.isSelected ? .blue : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Song number
            Text("#\(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // Song details
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Song name
                    TextField("Song name", text: .init(
                        get: { song.name },
                        set: { viewModel.updateSong(song, name: $0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!song.isSelected)
                    .opacity(song.isSelected ? 1.0 : 0.6)
                    
                    // Artist name
                    TextField("Artist", text: .init(
                        get: { song.artist },
                        set: { viewModel.updateSong(song, artist: $0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!song.isSelected)
                    .opacity(song.isSelected ? 1.0 : 0.6)
                    
                    // Duration
                    TextField("MM:SS", text: .init(
                        get: { song.duration },
                        set: { viewModel.updateSong(song, duration: $0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .keyboardType(.numbersAndPunctuation)
                    .disabled(!song.isSelected)
                    .opacity(song.isSelected ? 1.0 : 0.6)
                }
                
                // Duration validation indicator
                if !song.duration.isEmpty && !song.hasValidDuration {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Invalid time format. Use MM:SS or H:MM:SS")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                }
            }
            
            // Remove button
            if viewModel.songs.count > 1 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.removeSong(song)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(song.isSelected ? Color(.systemBackground) : Color(.systemGray6))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: song.isSelected)
    }
}

#Preview {
    VStack(spacing: 16) {
        SongRowView(
            viewModel: PlaylistViewModel(),
            song: Song(name: "Bohemian Rhapsody", artist: "Queen", duration: "5:55"),
            index: 0
        )
        
        SongRowView(
            viewModel: PlaylistViewModel(),
            song: Song(name: "Hotel California", artist: "Eagles", duration: "6:30", isSelected: false),
            index: 1
        )
        
        SongRowView(
            viewModel: PlaylistViewModel(),
            song: Song(name: "", artist: "", duration: ""),
            index: 2
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}