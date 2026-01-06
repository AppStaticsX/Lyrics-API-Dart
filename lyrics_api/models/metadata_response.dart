/// Model for metadata response
class MetadataResponse {
  final bool success;
  final String? message;
  final MetadataData? data;
  final String? error;

  MetadataResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory MetadataResponse.fromJson(Map<String, dynamic> json) {
    return MetadataResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? MetadataData.fromJson(json['data']) : null,
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

class MetadataData {
  final String? trackId;
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArt;
  final String? releaseDate;
  final int? duration;
  final List<String>? genres;

  MetadataData({
    this.trackId,
    this.title,
    this.artist,
    this.album,
    this.albumArt,
    this.releaseDate,
    this.duration,
    this.genres,
  });

  factory MetadataData.fromJson(Map<String, dynamic> json) {
    return MetadataData(
      trackId: json['trackId'] ?? json['trackid'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      albumArt: json['albumArt'] ?? json['album_art'],
      releaseDate: json['releaseDate'] ?? json['release_date'],
      duration: json['duration'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackId': trackId,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'releaseDate': releaseDate,
      'duration': duration,
      'genres': genres,
    };
  }
}
