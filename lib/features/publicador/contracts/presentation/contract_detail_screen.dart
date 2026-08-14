import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/contract.dart';
import '../../../../shared/providers/upload_provider.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/contract_detail_controller.dart';

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void showErrorSnack(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString().replaceAll('Exception: ', '')),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

class ContractDetailScreen extends ConsumerWidget {
  const ContractDetailScreen({required this.contractId, super.key});

  final String contractId;

  static const Map<ContractStatus, (Color, Color)> _colors = {
    ContractStatus.pending: (AppColors.statusReviewBg, AppColors.statusReviewFg),
    ContractStatus.active: (AppColors.statusWinnerBg, AppColors.statusWinnerFg),
    ContractStatus.rejected: (AppColors.errorContainer, AppColors.onErrorContainer),
    ContractStatus.cancelled:
        (AppColors.surfaceContainerHighest, AppColors.onSurfaceVariant),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContract = ref.watch(contractDetailControllerProvider(contractId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalle de Contrato'),
      ),
      body: AsyncView(
        value: asyncContract,
        onRetry: () => ref.invalidate(contractDetailControllerProvider(contractId)),
        data: (contract) {
          final palette = _colors[contract.status]!;
          final counterpart = contract.soyContratante
              ? contract.contratado
              : contract.contratante;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contract.jobTypeName ?? 'Contrato',
                                style: AppTypography.headlineSm,
                              ),
                            ),
                            StatusBadge.custom(
                              label: contract.status.label,
                              background: palette.$1,
                              foreground: palette.$2,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          contract.soyContratante
                              ? 'Contrataste a ${counterpart?.nombre ?? "—"}'
                              : 'Te contrató ${counterpart?.nombre ?? "—"}',
                          style: AppTypography.bodyMd,
                        ),
                        if (counterpart?.email != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(counterpart!.email!, style: AppTypography.bodyMd),
                        ],
                        const Divider(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.base,
                          children: [
                            if (contract.salary != null)
                              Text(
                                DateFormats.money(
                                  contract.salary,
                                  contract.currency,
                                ),
                                style: AppTypography.labelLg
                                    .copyWith(color: AppColors.primary),
                              ),
                            if (contract.startDate != null)
                              Text(
                                'Inicio: ${DateFormats.short(contract.startDate)}',
                                style: AppTypography.labelMd,
                              ),
                            if (contract.duration != null)
                              Text(
                                'Duración: ${contract.duration}',
                                style: AppTypography.labelMd,
                              ),
                          ],
                        ),
                        if (contract.status == ContractStatus.cancelled) ...[
                          const Divider(height: AppSpacing.lg),
                          Text(
                            'Cancelado por: ${contract.cancelledBy?.nombre ?? "—"}',
                            style: AppTypography.labelMd,
                          ),
                          if (contract.cancelJustification != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Motivo: ${contract.cancelJustification}',
                              style: AppTypography.bodyMd,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (contract.status == ContractStatus.pending && contract.soyContratado)
                  _PendingActionCard(contractId: contract.id),

                if (contract.status == ContractStatus.pending && contract.soyContratante)
                  _TermsFormCard(contract: contract),

                if (contract.status == ContractStatus.active)
                  _ActiveSection(contract: contract),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PendingActionCard extends ConsumerStatefulWidget {
  const _PendingActionCard({required this.contractId});

  final String contractId;

  @override
  ConsumerState<_PendingActionCard> createState() => _PendingActionCardState();
}

class _PendingActionCardState extends ConsumerState<_PendingActionCard> {
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(contractDetailControllerProvider(widget.contractId).notifier)
          .accept();
      if (mounted) showSuccessSnack(context, 'Contrato aceptado exitosamente.');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(contractDetailControllerProvider(widget.contractId).notifier)
          .reject();
      if (mounted) showSuccessSnack(context, 'Contrato rechazado.');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Responder Propuesta', style: AppTypography.headlineSm),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Revisa los términos. Si estás de acuerdo, acepta para activar el contrato.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _reject,
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _accept,
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _TermsFormCard extends ConsumerStatefulWidget {
  const _TermsFormCard({required this.contract});

  final Contract contract;

  @override
  ConsumerState<_TermsFormCard> createState() => _TermsFormCardState();
}

class _TermsFormCardState extends ConsumerState<_TermsFormCard> {
  final _salary = TextEditingController();
  final _currency = TextEditingController(text: 'DOP');
  final _duration = TextEditingController();
  DateTime? _startDate;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.contract.salary != null) {
      _salary.text = widget.contract.salary.toString();
    }
    if (widget.contract.currency != null) {
      _currency.text = widget.contract.currency!;
    }
    if (widget.contract.duration != null) {
      _duration.text = widget.contract.duration!;
    }
    _startDate = widget.contract.startDate;
  }

  @override
  void dispose() {
    _salary.dispose();
    _currency.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _saveTerms() async {
    final salaryVal = double.tryParse(_salary.text.trim());
    final durationVal = _duration.text.trim();
    if (salaryVal == null || durationVal.isEmpty || _startDate == null) {
      showErrorSnack(context, 'Completa todos los campos obligatorios.');
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(contractDetailControllerProvider(widget.contract.id).notifier)
          .updateTerms(
            salary: salaryVal,
            currency: _currency.text.trim(),
            startDate: _startDate!,
            duration: durationVal,
          );
      if (mounted) showSuccessSnack(context, 'Términos actualizados.');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Fijar Términos del Contrato', style: AppTypography.headlineSm),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _salary,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto/Salario'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _currency,
                enabled: !_busy,
                decoration: const InputDecoration(labelText: 'Moneda (Ej: DOP, USD)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _duration,
                enabled: !_busy,
                decoration: const InputDecoration(labelText: 'Duración (Ej: 2 semanas)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startDate == null
                      ? 'Fecha de inicio no seleccionada'
                      : 'Inicio: ${DateFormats.short(_startDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _busy
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _busy ? null : _saveTerms,
                child: const Text('Guardar Términos'),
              ),
            ],
          ),
        ),
      );
}

class _ActiveSection extends ConsumerStatefulWidget {
  const _ActiveSection({required this.contract});

  final Contract contract;

  @override
  ConsumerState<_ActiveSection> createState() => _ActiveSectionState();
}

class _ActiveSectionState extends ConsumerState<_ActiveSection> {
  final _comment = TextEditingController();
  final _description = TextEditingController();
  PickedPhoto? _pickedPhoto;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final body = _comment.text.trim();
    if (body.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(contractDetailControllerProvider(widget.contract.id).notifier)
          .addComment(body);
      _comment.clear();
      if (mounted) showSuccessSnack(context, 'Comentario agregado.');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addPhoto() async {
    final picked = _pickedPhoto;
    final description = _description.text.trim();
    if (picked == null || description.isEmpty) return;
    setState(() => _busy = true);
    try {
      final upload = await ref.read(uploadRepositoryProvider).uploadImage(
            bytes: picked.bytes,
            filename: picked.filename,
          );
      await ref
          .read(contractDetailControllerProvider(widget.contract.id).notifier)
          .addPhoto(photo: upload.url, description: description);
      setState(() {
        _pickedPhoto = null;
        _description.clear();
      });
      if (mounted) showSuccessSnack(context, 'Foto de evidencia agregada.');
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelContract() async {
    final justificationController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Contrato'),
        content: TextField(
          controller: justificationController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo / Justificación',
            hintText: 'Explica el motivo de la cancelación',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final text = justificationController.text.trim();
      if (text.isEmpty) {
        if (mounted) showErrorSnack(context, 'Debes ingresar una justificación.');
        return;
      }
      setState(() => _busy = true);
      try {
        await ref
            .read(contractDetailControllerProvider(widget.contract.id).notifier)
            .cancel(text);
        if (mounted) showSuccessSnack(context, 'Contrato cancelado.');
      } catch (error) {
        if (mounted) showErrorSnack(context, error);
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Contrato activo', style: AppTypography.headlineSm),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Solo los contratos activos permiten comentar y subir evidencia.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _comment,
                enabled: !_busy,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: 'Escribe un avance o actualización',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FilledButton.icon(
                onPressed: _busy ? null : _addComment,
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Agregar comentario'),
              ),
              const Divider(height: AppSpacing.lg),
              PhotoPickerField(
                label: 'Foto de evidencia',
                photo: _pickedPhoto,
                onPicked: (value) => setState(() => _pickedPhoto = value),
              ),
              TextField(
                controller: _description,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la foto',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              FilledButton.icon(
                onPressed: _busy ? null : _addPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Subir foto de evidencia'),
              ),
              if (widget.contract.comments.isNotEmpty) ...[
                const Divider(height: AppSpacing.lg),
                Text('Comentarios', style: AppTypography.headlineSm),
                const SizedBox(height: AppSpacing.xs),
                for (final item in widget.contract.comments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.comment_outlined),
                    title: Text(item.body),
                    subtitle: Text(
                      '${item.by?.nombre ?? 'Usuario'} · ${DateFormats.short(item.createdAt)}',
                    ),
                  ),
              ],
              if (widget.contract.photos.isNotEmpty) ...[
                const Divider(height: AppSpacing.lg),
                Text('Evidencias Fotográficas', style: AppTypography.headlineSm),
                const SizedBox(height: AppSpacing.sm),
                for (final item in widget.contract.photos)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (item.url.isNotEmpty)
                          Image.network(
                            item.url,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                        ListTile(
                          title: Text(item.description),
                          subtitle: Text(
                            '${item.by?.nombre ?? 'Usuario'} · ${DateFormats.short(item.createdAt)}',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const Divider(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: _busy ? null : _cancelContract,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar contrato'),
              ),
            ],
          ),
        ),
      );
}