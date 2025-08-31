import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Section
                    HeaderSection()
                    
                    // Songs Input Section
                    SongsSection(viewModel: viewModel)
                    
                    // Time Settings Section
                    TimeSettingsSection(viewModel: viewModel)
                    
                    // Results Section
                    if viewModel.hasValidSongs {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "Results", icon: "chart.bar.xaxis")
                            ResultsView(viewModel: viewModel)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tip Section
                    TipSection()
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Playlist Timer")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showingImportSheet) {
                ImportView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Header Section

struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                    .font(.system(size: 32, weight: .medium))
                
                Text("Playlist Timer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text("Calculate your playlist duration and plan your perfect timing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Songs Section

struct SongsSection: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Songs & Durations", icon: "music.note.list")
                
                Spacer()
                
                Button(action: {
                    viewModel.showingImportSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Import")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal)
            
            // Songs List
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.songs.enumerated()), id: \.element.id) { index, song in
                    SongRowView(viewModel: viewModel, song: song, index: index)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal)
            
            // Add Song Button
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    viewModel.addSong()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Another Song")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Time Settings Section

struct TimeSettingsSection: View {
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Time Settings", icon: "gear")
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Start Time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Time (optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker(
                        "Start Time",
                        selection: Binding(
                            get: { viewModel.startTime ?? Date() },
                            set: { viewModel.setStartTime($0) }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    
                    if viewModel.startTime != nil {
                        Button("Clear Start Time") {
                            viewModel.setStartTime(nil)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                // Target End Time
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target End Time")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker(
                        "Target End Time",
                        selection: Binding(
                            get: { viewModel.targetEndTime ?? Date().addingTimeInterval(3600) },
                            set: { viewModel.setTargetEndTime($0) }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                    
                    if viewModel.targetEndTime != nil {
                        Button("Clear Target Time") {
                            viewModel.setTargetEndTime(nil)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 18, weight: .medium))
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Tip Section

struct TipSection: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .foregroundColor(.orange)
                .font(.system(size: 16))
            
            Text("Tip: Enter song durations in MM:SS format (e.g., 3:45) or H:MM:SS for longer tracks")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}