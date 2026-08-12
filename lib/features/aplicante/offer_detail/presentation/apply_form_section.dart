import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/dynamic_form/dynamic_form.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/apply_controller.dart';

/// Formulario de aplicación (módulo 6).
///
/// Usa `DynamicForm` SIN modificarlo: las preguntas salen del array
/// `questions` de la oferta, cada una un `CustomField`.
class ApplyFormSection extends ConsumerStatefulWidget {
  const ApplyFormSection({super.key, required this.offer});

  final Offer offer;

  @override
  ConsumerState<ApplyFormSection> createState() => _ApplyFormSectionState();
}

class _ApplyFormSectionState extends ConsumerState<ApplyFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  late final DynamicFormController _dynamicForm;

  @override
  void initState() {
    super.initState();
    _dynamicForm = DynamicFormController(
      fields: widget.offer.questions.map((q) => q.field.copyWith(key: q.id)).toList(),
    );
  }

  @override
  void dispose() {
    _comment.dispose();
    _dynamicForm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final commentValid = _formKey.currentState?.validate() ?? false;
    final dynamicValid = _dynamicForm.validate();
    if (!commentValid || !dynamicValid) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(applyControllerProvider.notifier).submit(
          offerId: widget.offer.id,
          comment: _comment.text,
          answers: _dynamicForm.toAnswersList(),
        );

    if (!mounted) return;
    if (ok) {
      showSuccessSnack(context, '¡Aplicación enviada! Te avisaremos.');
      Navigator.of(context).maybePop();
    } else {
      final error = ref.read(applyControllerProvider).error;
      if (error != null) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(applyControllerProvider).isLoading;
    final alreadyApplied = widget.offer.myApplicationStatus != null;

    if (alreadyApplied) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.onSecondaryContainer),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Ya aplicaste a esta oferta. Sigue el estado desde '
                '"Mis aplicaciones".',
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.onSecondaryContainer),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Formulario de aplicación', style: AppTypography.headlineSm),
            const SizedBox(height: AppSpacing.md),

            // Preguntas dinámicas de la oferta (si las hay).
            DynamicForm(controller: _dynamicForm, enabled: !loading),

            // Comentario obligatorio según el schema.
            Form(
              key: _formKey,
              child: AppTextField(
                fieldKey: const Key('apply_comment'),
                label: 'Comentario adicional',
                hint: 'Explica brevemente por qué eres ideal para este trabajo…',
                controller: _comment,
                maxLines: 4,
                enabled: !loading,
                validator: (v) =>
                    Validators.minLength(v, 10, label: 'El comentario'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              key: const Key('apply_submit'),
              label: 'Aplicar ahora',
              cta: true,
              loading: loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
