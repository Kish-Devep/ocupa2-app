import '../../core/network/json.dart';

class Experience {
  const Experience({
    required this.id,
    required this.title,
    required this.description,
    this.jobTypeKey,
    this.certificateImage,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String? jobTypeKey;
  final String? certificateImage;
  final DateTime? createdAt;

  factory Experience.fromJson(JsonMap json) => Experience(
        id: asString(pick(json, ['id', '_id'])),
        title: asString(json['title']),
        description: asString(json['description']),
        jobTypeKey: asStringOrNull(json['jobTypeKey']),
        certificateImage: asStringOrNull(
          pick(json, ['certificateImage', 'certificate', 'image']),
        ),
        createdAt: asDate(json['createdAt']),
      );
}
