import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../state/explore_offers_controller.dart';

/// Módulo 13 — usa lat/lng de cada oferta del listado de /offers.
/// Sin API key: tiles de OpenStreetMap vía flutter_map.
class OffersMapScreen extends ConsumerStatefulWidget {
  const OffersMapScreen({super.key});

  @override
  ConsumerState<OffersMapScreen> createState() => _OffersMapScreenState();
}

class _OffersMapScreenState extends ConsumerState<OffersMapScreen> {
  final MapController _controller = MapController();
  Offer? _selected;

  @override
  Widget build(BuildContext context) {
    final offers = ref.watch(mappableOffersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mapa de ofertas'),
      ),
      body: AsyncView(
        value: offers,
        onRetry: () => ref.invalidate(exploreOffersProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.location_off_outlined,
              title: 'Sin ofertas georreferenciadas',
              message: 'Ninguna oferta activa tiene coordenadas registradas.',
            );
          }

          final center = items.first.location ?? GeoPoint.santoDomingo;

          return Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: LatLng(center.lat, center.lng),
                  initialZoom: 11,
                  onTap: (_, __) => setState(() => _selected = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ocupa2.app',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final offer in items)
                        Marker(
                          point: LatLng(
                            offer.location!.lat,
                            offer.location!.lng,
                          ),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = offer),
                            child: Icon(
                              Icons.location_on,
                              size: _selected?.id == offer.id ? 44 : 34,
                              color: _selected?.id == offer.id
                                  ? AppColors.cta
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (_selected != null)
                Positioned(
                  left: AppSpacing.containerMargin,
                  right: AppSpacing.containerMargin,
                  bottom: AppSpacing.containerMargin,
                  child: Card(
                    child: InkWell(
                      onTap: () =>
                          context.push(AppRoutes.offerDetail(_selected!.id)),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selected!.displayTitle,
                                      style: AppTypography.labelLg),
                                  const SizedBox(height: AppSpacing.base),
                                  Text(_selected!.address,
                                      style: AppTypography.bodyMd,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                    DateFormats.money(
                                      _selected!.payment?.amount,
                                      _selected!.payment?.currency,
                                    ),
                                    style: AppTypography.labelLg
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
