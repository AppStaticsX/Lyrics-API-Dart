import '../services/lyrics_api_service.dart';
import '../../../main.dart';

/// Test function to demonstrate lyrics API usage
/// Call this function from anywhere in your app to test the lyrics service
Future<void> testLyricsExamples() async {

  try {
    // Example 1: Get lyrics by track ID
    print('=== Example 1: Get Lyrics by Track ID ===');
    final lyricsResponse = await lyricsService.getLyricsByTrackId(
      platform: Platform.spotify,
      trackId: '3n3Ppam7vgaVa1iaRUc9Lp', // Example Spotify track ID
    );

    if (lyricsResponse.success && lyricsResponse.data != null) {
      print('Title: ${lyricsResponse.data!.title}');
      print('Artist: ${lyricsResponse.data!.artist}');
      print('Lyrics:\n${lyricsResponse.data!.lyrics}');
    } else {
      print('Error: ${lyricsResponse.error ?? lyricsResponse.message}');
    }

    print('\n=== Example 2: Get Lyrics by Title and Artist ===');
    final lyricsResponse2 = await lyricsService.getLyricsByTitleAndArtist(
      platform: Platform.musixmatch,
      title: 'Shape of You',
      artist: 'Ed Sheeran',
    );

    if (lyricsResponse2.success && lyricsResponse2.data != null) {
      print('Title: ${lyricsResponse2.data!.title}');
      print('Artist: ${lyricsResponse2.data!.artist}');
      print('Lyrics preview: ${lyricsResponse2.data!.lyrics?.substring(0, 100)}...');
    }

    print('\n=== Example 3: Get Translated Lyrics ===');
    final translatedLyrics = await lyricsService.getLyricsByTitleAndArtist(
      platform: Platform.musixmatch,
      title: 'Despacito',
      artist: 'Luis Fonsi',
      translate: 'en', // Translate to English
    );

    if (translatedLyrics.success && translatedLyrics.data != null) {
      print('Title: ${translatedLyrics.data!.title}');
      print('Translated to: ${translatedLyrics.data!.language}');
      print('Lyrics preview: ${translatedLyrics.data!.lyrics?.substring(0, 100)}...');
    }

    print('\n=== Example 4: Get Track Metadata ===');
    final metadataResponse = await lyricsService.getMetadata(
      platform: Platform.musixmatch,
      title: 'Bohemian Rhapsody',
    );

    if (metadataResponse.success && metadataResponse.data != null) {
      final metadata = metadataResponse.data!;
      print('Title: ${metadata.title}');
      print('Artist: ${metadata.artist}');
      print('Album: ${metadata.album}');
      print('Release Date: ${metadata.releaseDate}');
      print('Duration: ${metadata.duration}s');
      print('Genres: ${metadata.genres?.join(', ')}');
    }

    print('\n=== Example 5: Get Recommendations ===');
    final recommendationsResponse = await lyricsService.getRecommendations(
      platform: Platform.musixmatch,
      country: 'US',
    );

    if (recommendationsResponse.success && recommendationsResponse.data != null) {
      print('Top Tracks:');
      for (var track in recommendationsResponse.data!.take(5)) {
        print('${track.rank}. ${track.title} - ${track.artist}');
      }
    }
  } on LyricsApiException catch (e) {
    print('API Error: $e');
  } catch (e) {
    print('Unexpected error: $e');
  }
}
