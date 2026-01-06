import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lyrics_response.dart';
import '../models/metadata_response.dart';
import '../models/recommendation_response.dart';

/// Platform types supported by the API
enum Platform {
  spotify,
  musixmatch,
  genius,
}

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
      final platformName = platform.name;
      final uri = Uri.parse('$baseUrl/v2/$platformName/lyrics')
          .replace(queryParameters: params);

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

  /// Get metadata for a track
  /// 
  /// [platform] - The platform to fetch from
  /// [title] - The song title to search for
  Future<MetadataResponse> getMetadata({
    required Platform platform,
    required String title,
  }) async {
    try {
      final platformName = platform.name;
      final uri = Uri.parse('$baseUrl/v2/$platformName/metadata')
          .replace(queryParameters: {'title': title});

      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MetadataResponse.fromJson(jsonData);
      } else if (response.statusCode == 429) {
        throw LyricsApiException(
          'Rate limit exceeded. Please try again later.',
          response.statusCode,
        );
      } else {
        throw LyricsApiException(
          'Failed to fetch metadata: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is LyricsApiException) rethrow;
      throw LyricsApiException('Request failed: $e');
    }
  }

  /// Get recommended tracks
  /// 
  /// [platform] - The platform to fetch from
  /// [country] - Optional country code (e.g., 'US', 'GB', 'FR')
  Future<RecommendationResponse> getRecommendations({
    required Platform platform,
    String? country,
  }) async {
    try {
      final platformName = platform.name;
      final params = {
        if (country != null) 'country': country,
      };

      final uri = Uri.parse('$baseUrl/v2/$platformName/recommendation')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return RecommendationResponse.fromJson(jsonData);
      } else if (response.statusCode == 429) {
        throw LyricsApiException(
          'Rate limit exceeded. Please try again later.',
          response.statusCode,
        );
      } else {
        throw LyricsApiException(
          'Failed to fetch recommendations: ${response.body}',
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
