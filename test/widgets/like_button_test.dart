import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/offer.dart';

void main() {
  test('el estado optimista invierte likedByMe y ajusta el contador', () {
    final offer = Offer.fromJson(<String, dynamic>{
      'id': 'o1',
      'jobTypeKey': 'chofer',
      'contractType': 'temporal',
      'description': 'Trabajo',
      'address': 'Bonao',
      'likedByMe': false,
      'likesCount': 0,
    });
    final next = offer.copyWith(likedByMe: true, likesCount: 1);
    expect(next.likedByMe, isTrue);
    expect(next.likesCount, 1);
  });
}