import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyrics_response.dart';

/// Platform types supported by the API
enum Platform { spotify, musixmatch, genius, lrclib }

/// Exception thrown when API request fails
class LyricsApiException implements Exception {
  final String message;
  final int? statusCode;

  LyricsApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'LyricsApiException: $message (Status: $statusCode)';
}

/// Main API service for lyrics
class LyricsApiService {
  final String baseUrl;
  final http.Client? client;
  final Duration timeout;

  LyricsApiService({
    required this.baseUrl,
    this.client,
    this.timeout = const Duration(seconds: 30),
  });

  http.Client get _client => client ?? http.Client();

  /// Get lyrics by track ID
  ///
  /// [platform] - The platform to fetch from (spotify, musixmatch, genius)
  /// [trackId] - The track ID from the platform
  /// [translate] - Optional language code for translation (e.g., 'es', 'fr')
  Future<LyricsResponse> getLyricsByTrackId({
    required Platform platform,
    required String trackId,
    String? translate,
  }) async {
    final params = {
      'trackid': trackId,
      if (translate != null) 'translate': translate,
    };

    return _getLyrics(platform, params);
  }

  /// Get lyrics by title and artist
  ///
  /// [platform] - The platform to fetch from
  /// [title] - The song title
  /// [artist] - The artist name
  /// [translate] - Optional language code for translation
  Future<LyricsResponse> getLyricsByTitleAndArtist({
    required Platform platform,
    required String title,
    required String artist,
    String? translate,
  }) async {
    final params = {
      'title': title,
      'artist': artist,
      if (translate != null) 'translate': translate,
    };

    return _getLyrics(platform, params);
  }

  /// Internal method to fetch lyrics
  Future<LyricsResponse> _getLyrics(
    Platform platform,
    Map<String, String> params,
  ) async {
    try {
      // Handle LRCLIB specially as it has a different API structure and host
      if (platform == Platform.lrclib) {
        String? title = params['title'];
        String? artist = params['artist'];

        // Clean up artist
        if (artist != null &&
            (artist.toLowerCase() == 'unknown' || artist.trim().isEmpty)) {
          artist = null;
        }

        // Helper to parse LRCLIB JSON
        LyricsResponse parseLrcLibJson(Map<String, dynamic> data) {
          return LyricsResponse(
            success: true,
            data: LyricsData(
              trackId: data['id']?.toString(),
              title: data['trackName'],
              artist: data['artistName'],
              lyrics: data['syncedLyrics'] ?? data['plainLyrics'],
              platform: 'lrclib',
              language: 'en',
            ),
          );
        }

        // Strategy 1: Direct Get (if we have both title and artist)
        if (title != null &&
            title.isNotEmpty &&
            artist != null &&
            artist.isNotEmpty) {
          final uri = Uri.parse('https://lrclib.net/api/get').replace(
            queryParameters: {'track_name': title, 'artist_name': artist},
          );

          final response = await _client.get(uri).timeout(timeout);

          if (response.statusCode == 200) {
            return parseLrcLibJson(json.decode(response.body));
          }
          // If 404 or 400, fall through to search
        }

        // Strategy 2: Search (fallback)
        final Map<String, String> searchParams = {};
        if (title != null && title.isNotEmpty) {
          searchParams['track_name'] = title;
        }
        if (artist != null && artist.isNotEmpty) {
          searchParams['artist_name'] = artist;
        }

        if (searchParams.isEmpty) {
          return LyricsResponse(
            success: false,
            message: 'Not enough info to search lyrics',
          );
        }

        final searchUri = Uri.parse(
          'https://lrclib.net/api/search',
        ).replace(queryParameters: searchParams);

        final searchResponse = await _client.get(searchUri).timeout(timeout);

        if (searchResponse.statusCode == 200) {
          final List<dynamic> results = json.decode(searchResponse.body);
          if (results.isNotEmpty) {
            // Pick the first result that has lyrics
            for (final item in results) {
              if (item['plainLyrics'] != null || item['syncedLyrics'] != null) {
                return parseLrcLibJson(item);
              }
            }
            // If no items had lyrics, just use the first one anyway or fail?
            // Usually they do have lyrics if returned.
            return parseLrcLibJson(results.first);
          }
          return LyricsResponse(success: false, message: 'Lyrics not found');
        } else {
          throw LyricsApiException(
            'Failed to search lyrics from LRCLIB: ${searchResponse.body}',
            searchResponse.statusCode,
          );
        }
      }

      final platformName = platform.name;
      final uri = Uri.parse(
        '$baseUrl/v2/$platformName/lyrics',
      ).replace(queryParameters: params);

      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LyricsResponse.fromJson(jsonData);
      } else if (response.statusCode == 429) {
        throw LyricsApiException(
          'Rate limit exceeded. Please try again later.',
          response.statusCode,
        );
      } else {
        throw LyricsApiException(
          'Failed to fetch lyrics: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LyricsApiException) rethrow;
      throw LyricsApiException('Request failed: $e');
    }
  }

  /// Dispose the HTTP client if it was created internally
  void dispose() {
    if (client == null) {
      _client.close();
    }
  }
}
