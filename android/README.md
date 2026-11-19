# Playlist Time Calculator – Android

Native Kotlin / Jetpack Compose app. `compileSdk` / `targetSdk` = **36** (Android 16), minSdk 26.
Package: `com.thelionsit.playlisttimer`.

## Build
    echo "sdk.dir=$ANDROID_HOME" > local.properties
    ./gradlew testDebugUnitTest      # unit tests
    ./gradlew bundleRelease          # app/build/outputs/bundle/release/app-release.aab

## Sign for Play
Create `keystore.properties` (git-ignored) in this folder:

    storeFile=/absolute/path/upload.jks
    storePassword=...
    keyAlias=...
    keyPassword=...

Then `./gradlew bundleRelease` produces a signed AAB. Enrol in Play App Signing when uploading.

## Play listing notes
Title and description must describe only what the app does: add songs (name/artist/m:ss),
tick songs on/off, import pasted lists, see total length, end time and fit against a target time.
No Spotify integration exists in the Android app, so don't mention it.
