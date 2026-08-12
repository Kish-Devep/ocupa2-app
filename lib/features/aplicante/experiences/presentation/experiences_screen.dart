import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../state/experiences_controller.dart';
import 'experience_form.dart';

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  void _openForm(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.containerMargin,
          right: AppSpacing.containerMargin,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nueva experiencia', style: AppTypography.headlineSm),
              const SizedBox(height: AppSpacing.md),
              ExperienceForm(
                onSaved: () async => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiences = ref.watch(experiencesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis experiencias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cta,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: AsyncView(
        value: experiences,
        onRetry: () => ref.invalidate(experiencesControllerProvider),
        data: (items) {
          if (items.isEmpty) {
            return EmptyView(
              icon: Icons.workspace_premium_outlined,
              title: 'Aún no tienes experiencias',
              message: 'Agrega tu historial laboral y sube tus certificados '
                  'para destacar entre los aplicantes.',
              action: FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar experiencia'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(experiencesControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                AppSpacing.containerMargin,
                AppSpacing.containerMargin,
                96,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final experience = items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (experience.certificateImage != null)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radius),
                              child: CachedNetworkImage(
                                imageUrl: experience.certificateImage!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(experience.title,
                                  style: AppTypography.labelLg),
                              const SizedBox(height: AppSpacing.base),
                              Text(experience.description,
                                  style: AppTypography.bodyMd),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(experiencesControllerProvider.notifier)
                                  .remove(experience.id);
                            } catch (error) {
                              if (context.mounted) {
                                showErrorSnack(context, error);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
