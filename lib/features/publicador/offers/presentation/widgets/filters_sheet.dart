import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/models/job_type.dart';
import '../../../../../shared/models/offer.dart';
import '../../../../../shared/providers/job_types_provider.dart';
import '../../state/offers_filter.dart';

/// Hoja de filtros. Los tipos de empleo salen SIEMPRE de GET /job-types.
class FiltersSheet extends ConsumerWidget {
  const FiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(offersFilterProvider);
    final notifier = ref.read(offersFilterProvider.notifier);
    final jobTypes = ref.watch(jobTypesProvider).valueOrNull ?? const <JobType>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtros', style: AppTypography.headlineSm),
                TextButton(
                  onPressed: () {
                    notifier.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Tipo de contrato', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: filter.contractType == null,
                  onSelected: (_) => notifier.setContractType(null),
                ),
                for (final type in ContractType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: filter.contractType == type,
                    onSelected: (_) => notifier.setContractType(type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tipo de empleo', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.xs),
            if (jobTypes.isEmpty)
              Text('Cargando tipos de empleo…', style: AppTypography.bodyMd)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.base,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: filter.jobTypeKey == null,
                        onSelected: (_) => notifier.setJobType(null),
                      ),
                      for (final type in jobTypes)
                        ChoiceChip(
                          label: Text(type.name),
                          selected: filter.jobTypeKey == type.key,
                          onSelected: (_) => notifier.setJobType(type.key),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ver resultados'),
            ),
          ],
        ),
      ),
    );
  }
}
