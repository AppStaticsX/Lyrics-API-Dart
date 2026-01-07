# Lyrics API Documentation

This document describes the structure and usage of the Lyrics API module within the Spotify Clone application.

## Overview

The Lyrics API module is designed to fetch song lyrics from various platforms. It provides a unified interface to interact with different lyrics providers, handling the specifics of each API internally.

## Key Components

### 1. `LyricsApiService`

Located at: `lib/modules/lyrics_api/services/lyrics_api_service.dart`

This is the main service class responsible for making network requests to fetch lyrics.

**Constructor:**
```dart
LyricsApiService({
  required String baseUrl, // Base URL for the lyrics API (except LRCLib)
  http.Client? client,     // Optional HTTP client for testing
  Duration timeout,        // Request timeout (default: 30s)
})
```

**Methods:**

*   `getLyricsByTrackId`: Fetches lyrics using a platform-specific track ID.
*   `getLyricsByTitleAndArtist`: Fetches lyrics using the song title and artist name.

### 2. `Platform` Enum

Supported platforms:
*   `Platform.spotify`
*   `Platform.musixmatch`
*   `Platform.genius`
*   `Platform.lrclib` (Handled directly via `https://lrclib.net`)

### 3. `LyricsResponse`

Located at: `lib/modules/lyrics_api/models/lyrics_response.dart`

Standardized response object returned by all API methods.

**Properties:**
*   `success`: Boolean indicating if the request was successful.
*   `message`: Status message or error description.
*   `data`: `LyricsData` object containing the actual lyrics.
*   `error`: Error details if any.

**`LyricsData` Properties:**
*   `title`, `artist`: Metadata of the track.
*   `lyrics`: The lyrics text (plain or synced).
*   `platform`: Source platform name.
*   `language`: Language code of the lyrics.

## Usage Examples

### 1. Direct Usage of `LyricsApiService`

```dart
// Initialize the service
final apiService = LyricsApiService(baseUrl: 'YOUR_API_BASE_URL');

// Fetch from LRCLib (Recommended as it's free and open)
try {
  final response = await apiService.getLyricsByTitleAndArtist(
    platform: Platform.lrclib,
    title: 'Shape of You',
    artist: 'Ed Sheeran',
  );

  if (response.success && response.data != null) {
    print('Lyrics: ${response.data!.lyrics}');
  } else {
    print('Error: ${response.message}');
  }
} catch (e) {
  print('Exception: $e');
}
```

### 2. Integration with Riverpod (`LyricsService`)

Located at: `lib/services/lyrics_service.dart`

The application uses `LyricsService` to automatically fetch lyrics for the currently playing song.

**Providers:**
*   `currentLyricsProvider`: Holds the lyrics (String) for the current song. `null` if not found.
*   `lyricsLoadingProvider`: Boolean indicating if lyrics are currently being fetched.
*   `lyricsServiceProvider`: The main provider that initializes the logic.

**How it works:**
The `LyricsService` listens to `currentSongProvider`. When the song changes, it automatically triggers `_fetchLyricsForSong`, which calls `LyricsApiService` (using LRCLib by default).

## LRCLib Specific Implementation

The `LRCLib` implementation in `LyricsApiService` employs a two-step strategy:

1.  **Direct Get**: Attempts to fetch directly using `https://lrclib.net/api/get` if both title and artist are available.
2.  **Search Fallback**: If the direct match fails, it searches using `https://lrclib.net/api/search` and picks the first result that contains lyrics.

Ref: `lib/modules/lyrics_api/services/lyrics_api_service.dart` (lines 78-163)
