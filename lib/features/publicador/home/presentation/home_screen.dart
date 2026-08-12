import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/job_type.dart';
import '../../../../shared/providers/job_types_provider.dart';
import '../../../../shared/widgets/offer_card.dart';
import '../../../aplicante/auth/state/session_controller.dart';
import '../../offers/state/explore_offers_controller.dart';
import '../../offers/state/offers_filter.dart';
import '../data/home_slides.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final jobTypes = ref.watch(jobTypesProvider);
    final featured = ref.watch(exploreOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocupa2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.newspaper_outlined),
            tooltip: 'Noticias y videos',
            onPressed: () => context.push(AppRoutes.newsVideos),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Mapa de ofertas',
            onPressed: () => context.push(AppRoutes.map),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(exploreOffersProvider);
          ref.invalidate(jobTypesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              child: Text(
                'Hola, ${user?.firstName ?? user?.displayName ?? ''}'.trim(),
                style: AppTypography.headlineMd,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Slider estático
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                ),
                itemCount: homeSlides.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final slide = homeSlides[index];
                  return Container(
                    width: 280,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: slide.background,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(slide.icon, size: 36, color: slide.foreground),
                        const Spacer(),
                        Text(
                          slide.title,
                          style: AppTypography.headlineSm
                              .copyWith(color: slide.foreground),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          slide.subtitle,
                          style: AppTypography.bodyMd.copyWith(
                            color: slide.foreground.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Categorías desde GET /job-types (nunca hardcodeadas)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              child: Text('Categorías populares', style: AppTypography.headlineSm),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 96,
              child: jobTypes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                  ),
                  child: Text('No pudimos cargar las categorías.',
                      style: AppTypography.bodyMd),
                ),
                data: (types) => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerMargin,
                  ),
                  itemCount: types.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _CategoryChip(jobType: types[index]),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ofertas destacadas', style: AppTypography.headlineSm),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.explore),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            featured.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                ),
                child: Text('No pudimos cargar las ofertas.',
                    style: AppTypography.bodyMd),
              ),
              data: (offers) {
                final top = offers.take(5).toList();
                if (top.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerMargin,
                    ),
                    child: Text('Todavía no hay ofertas publicadas.',
                        style: AppTypography.bodyMd),
                  );
                }
                return Column(
                  children: [
                    for (final offer in top)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.containerMargin,
                          0,
                          AppSpacing.containerMargin,
                          AppSpacing.sm,
                        ),
                        child: OfferCard(
                          offer: offer,
                          onTap: () =>
                              context.push(AppRoutes.offerDetail(offer.id)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  const _CategoryChip({required this.jobType});

  final JobType jobType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(offersFilterProvider.notifier).setJobType(jobType.key);
        context.go(AppRoutes.explore);
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: AppSpacing.touchTarget,
              height: AppSpacing.touchTarget,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handyman_outlined,
                  color: AppColors.onSecondaryContainer, size: 22),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              jobType.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd,
            ),
          ],
        ),
      ),
    );
  }
}
