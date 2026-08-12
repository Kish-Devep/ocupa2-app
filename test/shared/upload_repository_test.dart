import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/shared/repositories/upload_repository.dart';

import '../helpers/mocks.dart';

void main() {
  final bytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

  test('POST /uploads envía la imagen como data URI y devuelve la URL',
      () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/uploads',
        statusCode: 201,
        data: <String, dynamic>{
          'key': 'uploads/foto.png',
          'url': 'https://cdn.ocupa2.test/foto.png',
          'mime': 'image/png',
          'size': 5,
        },
      ),
    ]);

    final result = await UploadRepository(api.client)
        .uploadImage(bytes: bytes, filename: 'foto.png');

    expect(result.url, 'https://cdn.ocupa2.test/foto.png');
    expect(
      api.adapter.lastBody['image'],
      'data:image/png;base64,${base64Encode(bytes)}',
    );
    expect(api.adapter.lastBody['filename'], 'foto.png');
  });

  test('rechaza formatos no permitidos antes de tocar la red', () async {
    final api = TestApi.build(const <FakeRoute>[]);

    await expectLater(
      UploadRepository(api.client)
          .uploadImage(bytes: bytes, filename: 'documento.pdf'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.validation)),
    );
    expect(api.adapter.requests, isEmpty);
  });

  test('rechaza imágenes de más de 8 MB antes de tocar la red', () async {
    final api = TestApi.build(const <FakeRoute>[]);
    final huge = Uint8List(9 * 1024 * 1024);

    await expectLater(
      UploadRepository(api.client).uploadImage(bytes: huge, filename: 'big.jpg'),
      throwsA(isA<ApiException>()),
    );
    expect(api.adapter.requests, isEmpty);
  });

  test('422 cuando el base64 es inválido para el servidor', () async {
    final api = TestApi.build([
      FakeRoute.error(method: 'POST', path: '/uploads', statusCode: 422),
    ]);

    await expectLater(
      UploadRepository(api.client).uploadImage(bytes: bytes, filename: 'f.jpg'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.validation)),
    );
  });

  test('502 cuando el bucket no pudo almacenar la imagen', () async {
    final api = TestApi.build([
      FakeRoute.error(method: 'POST', path: '/uploads', statusCode: 502),
    ]);

    await expectLater(
      UploadRepository(api.client).uploadImage(bytes: bytes, filename: 'f.jpg'),
      throwsA(
          isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.storage)),
    );
  });
}
