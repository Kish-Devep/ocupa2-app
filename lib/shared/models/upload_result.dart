import '../../core/network/json.dart';

/// Respuesta 201 de POST /uploads: `{key, url, mime, size}`.
class UploadResult {
  const UploadResult({
    required this.url,
    this.key,
    this.mime,
    this.size,
  });

  final String url;
  final String? key;
  final String? mime;
  final int? size;

  factory UploadResult.fromJson(JsonMap json) => UploadResult(
        url: asString(json['url']),
        key: asStringOrNull(json['key']),
        mime: asStringOrNull(json['mime']),
        size: asInt(json['size']),
      );
}
