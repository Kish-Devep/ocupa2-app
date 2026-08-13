import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/offer_card.dart';
import '../state/my_likes_controller.dart';

class MyLikesScreen extends ConsumerWidget {
  const MyLikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likes = ref.watch(myLikesControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis me gusta'),
      ),
      body: AsyncView(
        value: likes,
        onRetry: () => ref.invalidate(myLikesControllerProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.favorite_border,
              title: 'Todavía no tienes me gusta',
              message: 'Guarda las ofertas que quieras revisar después.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(myLikesControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => OfferCard(
                offer: items[index],
                onTap: () => context.push(AppRoutes.offerDetail(items[index].id)),
              ),
            ),
          );
        },
      ),
    );
  }
}