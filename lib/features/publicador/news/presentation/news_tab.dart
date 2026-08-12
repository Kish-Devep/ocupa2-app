import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/news_item.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../state/news_controller.dart';

class NewsTab extends ConsumerWidget {
  const NewsTab({super.key});

  Future<void> _open(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(newsProvider);

    return AsyncView(
      value: news,
      onRetry: () => ref.invalidate(newsProvider),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.newspaper_outlined,
            title: 'Sin noticias por ahora',
            message: 'Vuelve más tarde para ver novedades del mercado laboral.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(newsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) =>
                _NewsCard(item: items[index], onTap: () => _open(items[index].url)),
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.onTap});

  final NewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  child: CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 88,
                      height: 88,
                      color: AppColors.surfaceContainer,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: AppColors.surfaceContainer,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.labelLg,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    if (item.summary != null)
                      Text(
                        item.summary!,
                        style: AppTypography.bodyMd,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      '${item.source ?? ''} · ${DateFormats.relative(item.date)}',
                      style: AppTypography.labelMd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
