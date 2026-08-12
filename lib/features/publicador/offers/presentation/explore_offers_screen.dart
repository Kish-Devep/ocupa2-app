import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/offer_card.dart';
import '../state/explore_offers_controller.dart';
import '../state/offers_filter.dart';
import 'widgets/filters_sheet.dart';

/// Módulo 12 — GET /offers con filtros jobTypeKey y contractType.
class ExploreOffersScreen extends ConsumerWidget {
  const ExploreOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(visibleOffersProvider);
    final filter = ref.watch(offersFilterProvider);
    final notifier = ref.read(offersFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Ver en el mapa',
            onPressed: () => context.push(AppRoutes.map),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerMargin,
              0,
              AppSpacing.containerMargin,
              AppSpacing.xs,
            ),
            child: TextField(
              onChanged: notifier.setQuery,
              decoration: InputDecoration(
                hintText: 'Buscar empleos o habilidades…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surfaceContainerLowest,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        builder: (_) => const FiltersSheet(),
                      ),
                    ),
                    if (filter.activeCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.cta,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${filter.activeCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: filter.contractType == null,
                    onSelected: (_) => notifier.setContractType(null),
                  ),
                ),
                for (final type in ContractType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(type.label),
                      selected: filter.contractType == type,
                      onSelected: (selected) =>
                          notifier.setContractType(selected ? type : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView(
              value: offers,
              onRetry: () => ref.invalidate(exploreOffersProvider),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyView(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: filter.isEmpty
                        ? 'Todavía no hay ofertas publicadas.'
                        : 'Prueba quitando algún filtro.',
                    action: filter.isEmpty
                        ? null
                        : OutlinedButton(
                            onPressed: notifier.clear,
                            child: const Text('Limpiar filtros'),
                          ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(exploreOffersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.containerMargin,
                      AppSpacing.xs,
                      AppSpacing.containerMargin,
                      96,
                    ),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.base),
                          child: Text(
                            '${items.length} '
                            '${items.length == 1 ? "resultado" : "resultados"}',
                            style: AppTypography.bodyMd,
                          ),
                        );
                      }
                      final offer = items[index - 1];
                      return OfferCard(
                        offer: offer,
                        onTap: () =>
                            context.push(AppRoutes.offerDetail(offer.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
