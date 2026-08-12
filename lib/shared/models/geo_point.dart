import '../../core/network/json.dart';

/// `OfferInput.location` → `{lat, lng}`.
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  static GeoPoint? fromJson(dynamic value) {
    if (value is! Map) return null;
    final json = asMap(value);
    final lat = asDouble(pick(json, ['lat', 'latitude']));
    final lng = asDouble(pick(json, ['lng', 'lon', 'longitude']));
    if (lat == null || lng == null) return null;
    return GeoPoint(lat: lat, lng: lng);
  }

  JsonMap toJson() => <String, dynamic>{'lat': lat, 'lng': lng};

  /// Centro de Santo Domingo, usado como fallback del mapa.
  static const GeoPoint santoDomingo = GeoPoint(lat: 18.4861, lng: -69.9312);
}
