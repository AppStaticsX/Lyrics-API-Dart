/// Model for recommendation response
class RecommendationResponse {
  final bool success;
  final String? message;
  final List<RecommendationTrack>? data;
  final String? error;

  RecommendationResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => RecommendationTrack.fromJson(item))
              .toList()
          : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
      'error': error,
    };
  }
}

class RecommendationTrack {
  final String? trackId;
  final String? title;
  final String? artist;
  final String? albumArt;
  final int? rank;

  RecommendationTrack({
    this.trackId,
    this.title,
    this.artist,
    this.albumArt,
    this.rank,
  });

  factory RecommendationTrack.fromJson(Map<String, dynamic> json) {
    return RecommendationTrack(
      trackId: json['trackId'] ?? json['trackid'],
      title: json['title'],
      artist: json['artist'],
      albumArt: json['albumArt'] ?? json['album_art'],
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'rank': rank,
    };
  }
}
