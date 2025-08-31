# Playlist Timer - iOS App

A comprehensive iOS application for calculating playlist durations and planning perfect timing for your music sessions.

## Features

### ⏱️ Time Calculations
- **Total Duration**: Calculate the total time of your playlist
- **End Time Prediction**: See when your playlist will finish (from now or custom start time)
- **Target Time Analysis**: Compare playlist duration against desired end time
- **Smart Recommendations**: Get advice on adding or removing songs

### 🎵 Playlist Management
- **Manual Entry**: Add songs with name, artist, and duration
- **Song Selection**: Toggle individual songs on/off
- **Batch Import**: Import playlist data from various formats
- **Live Updates**: All calculations update in real-time

### 🎧 Spotify Integration
- **Direct Import**: Connect your Spotify account to import playlists
- **Multiple Playlists**: Access all your Spotify playlists
- **Automatic Duration**: Song durations are imported automatically

### 📊 Smart Analytics
- **Quick Stats**: View total songs, selected count, and average length
- **Visual Feedback**: Color-coded results for easy understanding
- **Validation**: Input validation with helpful error messages

## App Store Deployment

### Prerequisites
1. **Apple Developer Account**: Required for App Store distribution
2. **Xcode 15+**: Latest version recommended
3. **iOS 16.0+**: Minimum deployment target

### Setup Instructions

#### 1. Configure Bundle Identifier
- Open `project.pbxproj`
- Replace `com.yourcompany.PlaylistTimeCalculator` with your unique bundle ID
- Format: `com.yourname.playlisttimer` or `com.yourcompany.playlisttimer`

#### 2. Update Development Team
- In Xcode, select the project file
- Go to "Signing & Capabilities"
- Add your Apple Developer Team ID

#### 3. App Store Connect Setup
1. Log into [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app with your bundle identifier
3. Fill in app metadata:
   - **App Name**: "Playlist Timer"
   - **Category**: Music
   - **Content Rights**: Your own content
   - **Age Rating**: 4+ (No objectionable content)

#### 4. Privacy Settings
The app includes these privacy-related features:
- **Network Access**: For Spotify API integration
- **No Personal Data Collection**: App doesn't collect user data
- **Optional Spotify Connection**: Users can use app without connecting

#### 5. App Store Assets Needed
Create these assets for App Store submission:
- **App Icon**: 1024x1024 pixels (already configured in Assets.xcassets)
- **Screenshots**: 
  - iPhone: 6.7", 6.5", 5.5" display sizes
  - iPad: 12.9", 11" display sizes (if supporting iPad)
- **App Preview Video**: Optional but recommended

### Build and Archive

1. **Set Release Configuration**:
   ```
   Product > Scheme > Edit Scheme > Run > Build Configuration > Release
   ```

2. **Archive the App**:
   ```
   Product > Archive
   ```

3. **Upload to App Store**:
   - In Organizer window, select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the upload process

### App Store Review Guidelines

The app complies with Apple's guidelines:
- ✅ **Functionality**: Clear purpose and functionality
- ✅ **Design**: Native iOS design using SwiftUI
- ✅ **Legal**: No copyrighted content, respects Spotify's terms
- ✅ **Privacy**: No personal data collection without disclosure
- ✅ **Performance**: Optimized for iOS devices

### Spotify Integration Notes

For production Spotify integration:
1. Register app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Add redirect URI: `playlist-timer://callback`
3. Store client secret securely (backend recommended)
4. Update `SpotifyManager.swift` with production OAuth flow

### Marketing Materials

#### App Store Description
```
Transform your music planning with Playlist Timer - the ultimate tool for calculating playlist durations and timing your perfect soundtrack.

KEY FEATURES:
• Calculate total playlist duration instantly
• Predict when your music will end
• Compare against target times
• Import from Spotify or paste playlist data
• Smart song selection and management
• Real-time calculations and feedback

Whether you're planning a workout, party, road trip, or study session, Playlist Timer ensures your music fits perfectly within your time constraints.

PERFECT FOR:
• Event planners and DJs
• Fitness enthusiasts
• Students and professionals
• Music lovers and audiophiles
• Anyone who wants perfect timing

Simple, intuitive, and powerful - download Playlist Timer today and take control of your music timing!
```

#### Keywords
- playlist, timer, music, duration, calculator, spotify, timing, songs, planner, audio

### Support and Maintenance

- **Version Updates**: Regular updates for iOS compatibility
- **Bug Reports**: Monitor App Store reviews and crash reports
- **Feature Requests**: Consider user feedback for future versions
- **Spotify API**: Monitor for API changes and deprecations

## Technical Architecture

- **Framework**: SwiftUI + Combine
- **Architecture**: MVVM pattern
- **Minimum iOS**: 16.0
- **Dependencies**: None (pure Swift)
- **Data Persistence**: UserDefaults for app state
- **Networking**: URLSession for Spotify API

## License

This project is ready for commercial distribution. Ensure you have proper rights to use any third-party resources.

---

**Ready for App Store submission!** Follow the deployment steps above to publish your app.