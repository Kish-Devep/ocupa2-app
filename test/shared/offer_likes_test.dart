import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/like_result.dart';

void main() {
  test('parsea el resultado exacto de like/unlike', () {
    final result = LikeResult.fromJson(<String, dynamic>{
      'liked': true,
      'likesCount': 1,
    });
    expect(result.liked, isTrue);
    expect(result.likesCount, 1);
  });
}