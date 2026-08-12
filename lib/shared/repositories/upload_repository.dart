import 'dart:typed_data';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json.dart';
import '../../core/utils/image_encoder.dart';
import '../models/upload_result.dart';

/// POST /uploads — usado por AMBAS áreas (certificado de experiencia en el
/// área A, foto obligatoria de la oferta en el área B).
class UploadRepository {
  UploadRepository(this._client);

  final ApiClient _client;

  /// `image` acepta base64 puro o data URI; aquí siempre se envía data URI.
  Future<UploadResult> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (!ImageEncoder.isAllowed(filename)) {
      throw const ApiException(
        kind: ApiErrorKind.validation,
        message: 'Formato no permitido. Usa JPG, PNG, WEBP o GIF.',
      );
    }
    if (bytes.lengthInBytes > ImageEncoder.maxBytes) {
      throw const ApiException(
        kind: ApiErrorKind.validation,
        message: 'La imagen supera el máximo de 8 MB.',
      );
    }

    return _client.post<UploadResult>(
      '/uploads',
      body: <String, dynamic>{
        'image': ImageEncoder.toDataUri(bytes, filename),
        'filename': filename,
      },
      parse: (data) => UploadResult.fromJson(asMap(data)),
    );
  }
}
