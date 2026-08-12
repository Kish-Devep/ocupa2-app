import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../auth/state/session_controller.dart';
import '../../experiences/presentation/experience_form.dart';
import '../state/complete_profile_controller.dart';

/// Módulo 2 — obligatorio en el primer acceso.
///
/// Sigue el stepper del mockup (1 Personal · 2 Laboral · 3 Fotos):
///  - Paso 1 → PUT /me/profile  (OBLIGATORIO, es lo que activa profileCompleted)
///  - Paso 2 → POST /me/experiences (opcional, se puede omitir)
///  - Paso 3 → POST /uploads + certificado de la experiencia (opcional)
///
/// Los pasos 2 y 3 están agrupados en `ExperienceForm`, el mismo widget que usa
/// la pantalla de Experiencias.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _cedula = TextEditingController();

  Gender? _gender;
  DateTime? _birthDate;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _firstName.text = user?.firstName ?? '';
    _lastName.text = user?.lastName ?? '';
    _cedula.text = user?.cedula ?? '';
    _gender = user?.gender;
    _birthDate = user?.birthDate;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _cedula.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('es'),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submitStep1() async {
    final validForm = _formKey.currentState?.validate() ?? false;
    final genderError = _gender == null;
    final birthError = Validators.birthDate(_birthDate);
    if (!validForm || genderError || birthError != null) {
      setState(() {});
      if (genderError) showErrorSnack(context, 'Selecciona tu género');
      return;
    }

    final ok = await ref.read(completeProfileControllerProvider.notifier).submit(
          firstName: _firstName.text,
          lastName: _lastName.text,
          cedula: _cedula.text,
          gender: _gender!,
          birthDate: _birthDate!,
        );

    if (!mounted) return;
    if (ok) {
      setState(() => _step = 1);
    } else {
      final error = ref.read(completeProfileControllerProvider).error;
      if (error != null) showErrorSnack(context, error);
    }
  }

  /// Ya con el perfil guardado, el guard del router permite salir.
  Future<void> _finish() async {
    await ref.read(sessionControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(completeProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocupa2'),
        actions: [
          if (_step > 0)
            TextButton(onPressed: _finish, child: const Text('Omitir')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Stepper(current: _step),
                const SizedBox(height: AppSpacing.lg),
                if (_step == 0) ..._buildStep1(loading) else _buildStep2(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep1(bool loading) {
    final birthError = Validators.birthDate(_birthDate);
    return [
      Text('Completa tu perfil',
          textAlign: TextAlign.center, style: AppTypography.headlineLgMobile),
      const SizedBox(height: AppSpacing.base),
      Text(
        'Necesitamos estos datos antes de que puedas aplicar o publicar.',
        textAlign: TextAlign.center,
        style: AppTypography.bodyMd,
      ),
      const SizedBox(height: AppSpacing.lg),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              fieldKey: const Key('profile_cedula'),
              label: 'Cédula de identidad',
              hint: '000-0000000-0',
              controller: _cedula,
              keyboardType: TextInputType.number,
              inputFormatters: [LengthLimitingTextInputFormatter(13)],
              validator: Validators.cedula,
              enabled: !loading,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Nombre',
                    hint: 'Juan',
                    controller: _firstName,
                    enabled: !loading,
                    validator: (v) => Validators.name(v, label: 'El nombre'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Apellido',
                    hint: 'Pérez',
                    controller: _lastName,
                    enabled: !loading,
                    validator: (v) => Validators.name(v, label: 'El apellido'),
                  ),
                ),
              ],
            ),
            Text('Género', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                for (final gender in Gender.values) ...[
                  Expanded(
                    child: _GenderOption(
                      gender: gender,
                      selected: _gender == gender,
                      onTap: loading ? null : () => setState(() => _gender = gender),
                    ),
                  ),
                  if (gender != Gender.values.last)
                    const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Fecha de nacimiento', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            InkWell(
              onTap: loading ? null : _pickBirthDate,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: InputDecorator(
                decoration: InputDecoration(errorText: birthError),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _birthDate == null
                            ? 'Selecciona tu fecha de nacimiento'
                            : DateFormats.long(_birthDate),
                        style: _birthDate == null
                            ? const TextStyle(color: AppColors.outline)
                            : AppTypography.bodyLg,
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Siguiente paso',
              icon: Icons.arrow_forward,
              loading: loading,
              onPressed: _submitStep1,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tu experiencia',
            textAlign: TextAlign.center, style: AppTypography.headlineLgMobile),
        const SizedBox(height: AppSpacing.base),
        Text(
          'Opcional, pero mejora mucho tus posibilidades. Puedes agregar más '
          'después desde tu perfil.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.lg),
        ExperienceForm(onSaved: _finish),
        const SizedBox(height: AppSpacing.md),
        TextButton(onPressed: _finish, child: const Text('Lo haré después')),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});

  final int current;

  static const List<String> _labels = ['Personal', 'Laboral', 'Fotos'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Column(
            children: [
              Container(
                width: AppSpacing.touchTarget,
                height: AppSpacing.touchTarget,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i <= current
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: AppTypography.labelLg.copyWith(
                    color: i <= current
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                _labels[i],
                style: AppTypography.labelMd.copyWith(
                  color: i <= current
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (i < _labels.length - 1)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Divider(),
              ),
            ),
        ],
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  final Gender gender;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: AppSpacing.touchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: selected ? AppColors.secondaryContainer : AppColors.outline,
          ),
        ),
        child: Text(
          gender.label,
          style: AppTypography.bodyMd.copyWith(
            color: selected ? AppColors.onSecondaryContainer : AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
