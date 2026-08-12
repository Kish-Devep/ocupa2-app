import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../state/my_applications_controller.dart';
import 'widgets/application_card.dart';

/// Módulo 5 — GET /me/applications con filtro por estado.
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(myApplicationsControllerProvider);
    final filter = ref.watch(applicationsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis aplicaciones'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
                vertical: AppSpacing.xs,
              ),
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: filter == null,
                  onSelected: () =>
                      ref.read(applicationsFilterProvider.notifier).state = null,
                ),
                for (final status in ApplicationStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: filter == status,
                    onSelected: () => ref
                        .read(applicationsFilterProvider.notifier)
                        .state = status,
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView(
              value: applications,
              onRetry: () => ref.invalidate(myApplicationsControllerProvider),
              data: (items) {
                final visible = filter == null
                    ? items
                    : items.where((a) => a.status == filter).toList();

                if (visible.isEmpty) {
                  return EmptyView(
                    icon: Icons.assignment_outlined,
                    title: items.isEmpty
                        ? 'Todavía no has aplicado'
                        : 'Nada en "${filter?.label}"',
                    message: items.isEmpty
                        ? 'Explora las ofertas disponibles y postúlate a la '
                            'que mejor encaje contigo.'
                        : 'Prueba con otro filtro.',
                    action: items.isEmpty
                        ? FilledButton(
                            onPressed: () => context.go(AppRoutes.explore),
                            child: const Text('Explorar ofertas'),
                          )
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(myApplicationsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.containerMargin),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final application = visible[index];
                      return ApplicationCard(
                        application: application,
                        onTap: application.offerId == null
                            ? null
                            : () => context.push(
                                  AppRoutes.offerDetail(application.offerId!),
                                ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label, style: AppTypography.labelLg),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
