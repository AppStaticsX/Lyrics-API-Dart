/// Model for lyrics response
class LyricsResponse {
  final bool success;
  final String? message;
  final LyricsData? data;
  final String? error;

  LyricsResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory LyricsResponse.fromJson(Map<String, dynamic> json) {
    return LyricsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? LyricsData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class LyricsData {
  final String? trackId;
  final String? title;
  final String? artist;
  final String? lyrics;
  final String? platform;
  final String? language;

  LyricsData({
    this.trackId,
    this.title,
    this.artist,
    this.lyrics,
    this.platform,
    this.language,
  });

  factory LyricsData.fromJson(Map<String, dynamic> json) {
    return LyricsData(
      trackId: json['trackId'] ?? json['trackid'],
      title: json['title'],
      artist: json['artist'],
      lyrics: json['lyrics'],
      platform: json['platform'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'title': title,
      'artist': artist,
      'lyrics': lyrics,
      'platform': platform,
      'language': language,
    };
  }
}
