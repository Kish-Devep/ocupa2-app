import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/job_type.dart';
import '../../../../shared/providers/job_types_provider.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/experiences_controller.dart';

/// Formulario reutilizado en dos sitios: el paso 2-3 del onboarding y la
/// pantalla de Experiencias.
class ExperienceForm extends ConsumerStatefulWidget {
  const ExperienceForm({super.key, this.onSaved});

  final Future<void> Function()? onSaved;

  @override
  ConsumerState<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends ConsumerState<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  String? _jobTypeKey;
  PickedPhoto? _certificate;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await ref.read(experiencesControllerProvider.notifier).add(
            title: _title.text,
            description: _description.text,
            jobTypeKey: _jobTypeKey,
            certificateBytes: _certificate?.bytes,
            certificateFilename: _certificate?.filename,
          );
      if (!mounted) return;
      _title.clear();
      _description.clear();
      setState(() {
        _certificate = null;
        _jobTypeKey = null;
      });
      showSuccessSnack(context, 'Experiencia agregada.');
      await widget.onSaved?.call();
    } catch (error) {
      if (mounted) showErrorSnack(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobTypes = ref.watch(jobTypesProvider).valueOrNull ?? const <JobType>[];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Título',
            hint: 'Ej. Ayudante de electricista',
            controller: _title,
            enabled: !_saving,
            validator: (v) => Validators.minLength(v, 3, label: 'El título'),
          ),
          AppTextField(
            label: 'Descripción',
            hint: 'Cuenta qué hacías y por cuánto tiempo',
            controller: _description,
            maxLines: 4,
            enabled: !_saving,
            validator: (v) => Validators.minLength(v, 10, label: 'La descripción'),
          ),
          if (jobTypes.isNotEmpty) ...[
            Text('Tipo de trabajo (opcional)', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            DropdownButtonFormField<String>(
              value: _jobTypeKey,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Selecciona un tipo'),
              items: jobTypes
                  .map((t) => DropdownMenuItem(value: t.key, child: Text(t.name)))
                  .toList(),
              onChanged: _saving ? null : (v) => setState(() => _jobTypeKey = v),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          PhotoPickerField(
            label: 'Certificado (opcional)',
            helperText: 'Sube una foto de tu certificado o constancia.',
            photo: _certificate,
            onPicked: (photo) => setState(() => _certificate = photo),
          ),
          PrimaryButton(
            label: 'Guardar experiencia',
            loading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
