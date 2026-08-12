import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/offer_applicants_controller.dart';

/// Módulo 15 — aplicantes de una oferta (solo dueño) con calificación,
/// descarte, finalista y elección de ganador.
class OfferApplicantsScreen extends ConsumerWidget {
  const OfferApplicantsScreen({super.key, required this.offerId});

  final String offerId;

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    Application application,
    ApplicationStatus status,
  ) async {
    // Elegir ganador crea un contrato: se piden los términos opcionales.
    if (status == ApplicationStatus.winner) {
      final terms = await showModalBottomSheet<_WinnerTerms>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
        builder: (_) => _WinnerTermsSheet(
          applicantName: application.applicant?.displayName ?? 'este aplicante',
        ),
      );
      if (terms == null) return;

      try {
        await ref
            .read(offerApplicantsControllerProvider(offerId).notifier)
            .setStatus(
              application.id,
              status,
              salary: terms.salary,
              currency: terms.currency,
              startDate: terms.startDate,
              duration: terms.duration,
            );
        if (context.mounted) {
          showSuccessSnack(context, 'Ganador elegido. Se creó el contrato.');
        }
      } catch (error) {
        if (context.mounted) showErrorSnack(context, error);
      }
      return;
    }

    try {
      await ref
          .read(offerApplicantsControllerProvider(offerId).notifier)
          .setStatus(application.id, status);
      if (context.mounted) {
        showSuccessSnack(context, 'Aplicación marcada como ${status.label}.');
      }
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicants = ref.watch(offerApplicantsControllerProvider(offerId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Aplicantes'),
      ),
      body: AsyncView(
        value: applicants,
        onRetry: () =>
            ref.invalidate(offerApplicantsControllerProvider(offerId)),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.people_outline,
              title: 'Sin aplicantes todavía',
              message: 'Cuando alguien se postule, aparecerá aquí con su '
                  'información completa.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(offerApplicantsControllerProvider(offerId).notifier)
                .refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final application = items[index];
                final applicant = application.applicant;
                final isWinner = application.status == ApplicationStatus.winner;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                applicant?.initials ?? '?',
                                style: AppTypography.labelLg
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    applicant?.displayName ?? 'Aplicante',
                                    style: AppTypography.labelLg,
                                  ),
                                  Text(
                                    'Aplicó '
                                    '${DateFormats.relative(application.createdAt)}',
                                    style: AppTypography.labelMd,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: application.status),
                          ],
                        ),
                        if (application.comment != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radius),
                            ),
                            child: Text(application.comment!,
                                style: AppTypography.bodyMd),
                          ),
                        ],
                        if (application.answers.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          for (final answer in application.answers)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.base),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(answer.questionId,
                                        style: AppTypography.labelMd),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${answer.value}',
                                      textAlign: TextAlign.right,
                                      style: AppTypography.bodyMd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text('Calificación', style: AppTypography.labelMd),
                            const SizedBox(width: AppSpacing.xs),
                            for (var star = 1; star <= 5; star++)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  (application.rating ?? 0) >= star
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                  color: AppColors.cta,
                                ),
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(offerApplicantsControllerProvider(
                                                offerId)
                                            .notifier)
                                        .setRating(application.id, star);
                                  } catch (error) {
                                    if (context.mounted) {
                                      showErrorSnack(context, error);
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                        const Divider(),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            if (application.status != ApplicationStatus.discarded)
                              TextButton.icon(
                                onPressed: () => _updateStatus(context, ref,
                                    application, ApplicationStatus.discarded),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Descartar'),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
                              ),
                            if (application.status != ApplicationStatus.finalist &&
                                !isWinner)
                              TextButton.icon(
                                onPressed: () => _updateStatus(context, ref,
                                    application, ApplicationStatus.finalist),
                                icon: const Icon(Icons.star_border, size: 18),
                                label: const Text('Finalista'),
                              ),
                            if (!isWinner)
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.cta,
                                  minimumSize: const Size(0, 40),
                                ),
                                onPressed: () => _updateStatus(context, ref,
                                    application, ApplicationStatus.winner),
                                icon: const Icon(Icons.emoji_events_outlined,
                                    size: 18),
                                label: const Text('Elegir ganador'),
                              ),
                          ],
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

class _WinnerTerms {
  const _WinnerTerms({this.salary, this.currency, this.startDate, this.duration});

  final double? salary;
  final String? currency;
  final DateTime? startDate;
  final String? duration;
}

class _WinnerTermsSheet extends StatefulWidget {
  const _WinnerTermsSheet({required this.applicantName});

  final String applicantName;

  @override
  State<_WinnerTermsSheet> createState() => _WinnerTermsSheetState();
}

class _WinnerTermsSheetState extends State<_WinnerTermsSheet> {
  final _salary = TextEditingController();
  final _duration = TextEditingController();
  String _currency = 'DOP';
  DateTime? _startDate;

  @override
  void dispose() {
    _salary.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.containerMargin,
        right: AppSpacing.containerMargin,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Elegir ganador', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Al confirmar, se creará automáticamente un contrato con '
            '${widget.applicantName}. Los términos son opcionales y puedes '
            'fijarlos después.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _salary,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Salario'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _currency,
                  items: const [
                    DropdownMenuItem(value: 'DOP', child: Text('DOP')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? 'DOP'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _duration,
            decoration: const InputDecoration(
              labelText: 'Duración',
              hintText: '3 meses',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate ?? now,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
                locale: const Locale('es'),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Fecha de inicio'),
              child: Text(
                _startDate == null ? 'Opcional' : DateFormats.long(_startDate),
                style: AppTypography.bodyLg,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Confirmar ganador',
            cta: true,
            onPressed: () => Navigator.of(context).pop(
              _WinnerTerms(
                salary: double.tryParse(_salary.text.replaceAll(',', '').trim()),
                currency: _currency,
                startDate: _startDate,
                duration: _duration.text.trim().isEmpty ? null : _duration.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
