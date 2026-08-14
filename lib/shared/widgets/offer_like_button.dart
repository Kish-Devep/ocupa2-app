import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../models/offer.dart';
import '../providers/offer_like_controller.dart';
import 'error_snackbar.dart';

class OfferLikeButton extends ConsumerWidget {
  const OfferLikeButton({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(offerLikeProvider(offer));
    final controller = ref.read(offerLikeProvider(offer).notifier);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: Key('like_${offer.id}'),
          tooltip: current.likedByMe ? 'Quitar me gusta' : 'Dar me gusta',
          onPressed: () async {
            try {
              await controller.toggle();
            } catch (error) {
              if (context.mounted) showErrorSnack(context, error);
            }
          },
          icon: Icon(
            current.likedByMe ? Icons.favorite : Icons.favorite_border,
            color: current.likedByMe ? AppColors.cta : AppColors.onSurfaceVariant,
          ),
        ),
        Text('${current.likesCount}'),
      ],
    );
  }
}