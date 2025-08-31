import SwiftUI

struct ResultsView: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        LazyVStack(spacing: 16) {
            // Total Duration Card
            ResultCard(
                title: "Total Playlist Duration",
                value: viewModel.totalDuration,
                subtitle: nil,
                color: .blue,
                icon: "clock"
            )
            
            // End Time Card
            ResultCard(
                title: "Will End At",
                value: viewModel.endTimeFromStart ?? viewModel.endTimeFromNow,
                subtitle: viewModel.endTimeFromStart != nil ? "From start time" : "From now",
                color: .green,
                icon: "calendar.badge.clock"
            )
            
            // Time Until Target (if set)
            if let timeUntil = viewModel.timeUntilTarget {
                ResultCard(
                    title: "Time Until Target",
                    value: timeUntil,
                    subtitle: nil,
                    color: .purple,
                    icon: "timer"
                )
            }
            
            // Playlist vs Target Comparison (if target is set)
            if let timeDiff = viewModel.timeDifference {
                let color: Color = timeDiff.playlistTooLong ? .red : .orange
                let title = "Playlist vs Target Time"
                let value = timeDiff.playlistTooLong ? "Too long by: \(timeDiff.difference)" : "Extra time: \(timeDiff.difference)"
                let subtitle = timeDiff.playlistTooLong ? "Remove songs or shorten playlist" : "You can add more songs"
                
                ResultCard(
                    title: title,
                    value: value,
                    subtitle: subtitle,
                    color: color,
                    icon: "target"
                )
            }
            
            // Quick Stats Card
            if viewModel.hasValidSongs {
                let stats = viewModel.songStats
                QuickStatsCard(
                    totalSongs: stats.total,
                    selectedSongs: stats.selected,
                    averageLength: viewModel.averageSongLength
                )
            }
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18, weight: .medium))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct QuickStatsCard: View {
    let totalSongs: Int
    let selectedSongs: Int
    let averageLength: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .medium))
                
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Total songs:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalSongs)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Selected:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(selectedSongs)")
                        .fontWeight(.medium)
                        .foregroundColor(selectedSongs == totalSongs ? .green : .blue)
                }
                
                HStack {
                    Text("Average song length:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(averageLength)
                        .fontWeight(.medium)
                }
            }
            .font(.subheadline)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ScrollView {
        VStack {
            let viewModel = PlaylistViewModel()
            ResultsView(viewModel: viewModel)
                .onAppear {
                    viewModel.songs = Song.sampleSongs
                    viewModel.targetEndTime = Date().addingTimeInterval(3600) // 1 hour from now
                }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}