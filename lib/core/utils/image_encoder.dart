import 'dart:convert';
import 'dart:typed_data';

/// Convierte bytes de imagen al data URI que espera `POST /uploads`
/// (campo `image`: "base64 o data URI").
class ImageEncoder {
  const ImageEncoder._();

  /// 8 MB, según la documentación del endpoint.
  static const int maxBytes = 8 * 1024 * 1024;

  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  static String mimeFromFilename(String filename) {
    final ext = extensionOf(filename);
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  static String extensionOf(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot < 0 || dot == filename.length - 1) return 'jpg';
    return filename.substring(dot + 1).toLowerCase();
  }

  static bool isAllowed(String filename) =>
      allowedExtensions.contains(extensionOf(filename));

  static String toDataUri(Uint8List bytes, String filename) =>
      'data:${mimeFromFilename(filename)};base64,${base64Encode(bytes)}';
}
