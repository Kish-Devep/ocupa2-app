import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../models/geo_point.dart';

/// Mini-mapa para elegir la ubicación de la oferta (`OfferInput.location`).
/// Toca el mapa para mover el pin, o usa el botón de ubicación actual.
class LocationPickerField extends StatefulWidget {
  const LocationPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Ubicación del trabajo',
  });

  final GeoPoint? value;
  final ValueChanged<GeoPoint> onChanged;
  final String label;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  final MapController _controller = MapController();
  bool _locating = false;

  GeoPoint get _point => widget.value ?? GeoPoint.santoDomingo;

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final point = GeoPoint(lat: position.latitude, lng: position.longitude);
      widget.onChanged(point);
      _controller.move(LatLng(point.lat, point.lng), 15);
    } catch (_) {
      // Sin GPS disponible: el usuario puede tocar el mapa manualmente.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(_point.lat, _point.lng);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTypography.labelLg),
          const SizedBox(height: AppSpacing.base),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 13,
                      onTap: (_, latLng) => widget.onChanged(
                        GeoPoint(lat: latLng.latitude, lng: latLng.longitude),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ocupa2.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.cta,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    child: FloatingActionButton.small(
                      heroTag: 'loc_fab',
                      backgroundColor: AppColors.surfaceContainerLowest,
                      foregroundColor: AppColors.primary,
                      onPressed: _locating ? null : _useCurrentLocation,
                      child: _locating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Lat ${_point.lat.toStringAsFixed(5)} · Lng ${_point.lng.toStringAsFixed(5)}',
            style: AppTypography.labelMd,
          ),
        ],
      ),
    );
  }
}
