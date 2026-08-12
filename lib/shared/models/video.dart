import '../../core/network/json.dart';

/// Schema `Video`. Endpoint público.
class Video {
  const Video({
    required this.id,
    required this.title,
    this.youtubeId,
    this.url,
    this.description,
    this.thumbnail,
    this.order,
  });

  final String id;
  final String title;
  final String? youtubeId;
  final String? url;
  final String? description;
  final String? thumbnail;
  final int? order;

  factory Video.fromJson(JsonMap json) {
    final youtubeId = asStringOrNull(json['youtubeId']);
    return Video(
      id: asString(pick(json, ['id', '_id']), fallback: youtubeId ?? ''),
      title: asString(json['title']),
      youtubeId: youtubeId,
      url: asStringOrNull(json['url']),
      description: asStringOrNull(json['description']),
      thumbnail: asStringOrNull(json['thumbnail']) ??
          (youtubeId == null
              ? null
              : 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg'),
      order: asInt(json['order']),
    );
  }

  String? get watchUrl =>
      url ?? (youtubeId == null ? null : 'https://www.youtube.com/watch?v=$youtubeId');
}
