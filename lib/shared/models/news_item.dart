import '../../core/network/json.dart';

/// Schema `NewsItem`. Endpoint público (no requiere token).
class NewsItem {
  const NewsItem({
    required this.title,
    this.image,
    this.summary,
    this.date,
    this.url,
    this.source,
  });

  final String title;
  final String? image;
  final String? summary;
  final DateTime? date;
  final String? url;
  final String? source;

  factory NewsItem.fromJson(JsonMap json) => NewsItem(
        title: asString(json['title']),
        image: asStringOrNull(json['image']),
        summary: asStringOrNull(json['summary']),
        date: asDate(json['date']),
        url: asStringOrNull(json['url']),
        source: asStringOrNull(json['source']),
      );
}
