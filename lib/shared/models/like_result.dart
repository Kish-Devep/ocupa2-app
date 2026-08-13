import '../../core/network/json.dart';

class LikeResult {
  const LikeResult({required this.liked, required this.likesCount});

  final bool liked;
  final int likesCount;

  factory LikeResult.fromJson(JsonMap json) => LikeResult(
        liked: asBool(json['liked']),
        likesCount: asInt(json['likesCount']) ?? 0,
      );
}