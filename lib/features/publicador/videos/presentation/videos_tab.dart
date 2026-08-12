import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../state/videos_controller.dart';

class VideosTab extends ConsumerWidget {
  const VideosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(videosProvider);

    return AsyncView(
      value: videos,
      onRetry: () => ref.invalidate(videosProvider),
      data: (items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.play_circle_outline,
            title: 'Sin videos disponibles',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(videosProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final video = items[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final url = video.watchUrl;
                    if (url == null) return;
                    final uri = Uri.tryParse(url);
                    if (uri == null) return;
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: video.thumbnail == null
                                ? Container(color: AppColors.surfaceContainer)
                                : CachedNetworkImage(
                                    imageUrl: video.thumbnail!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.surfaceContainer,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.surfaceContainer,
                                    ),
                                  ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow,
                                color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title,
                                style: AppTypography.labelLg,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            if (video.description != null) ...[
                              const SizedBox(height: AppSpacing.base),
                              Text(
                                video.description!,
                                style: AppTypography.bodyMd,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
