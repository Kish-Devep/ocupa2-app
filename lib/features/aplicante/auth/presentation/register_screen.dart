import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/register_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _matricula = TextEditingController();

  @override
  void dispose() {
    for (final c in [_email, _firstName, _lastName, _password, _confirm, _matricula]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(registerControllerProvider.notifier).submit(
          email: _email.text,
          firstName: _firstName.text,
          lastName: _lastName.text,
          password: _password.text,
          referralMatricula: _matricula.text,
        );

    if (!mounted) return;
    if (!ok) {
      final error = ref.read(registerControllerProvider).error;
      if (error != null) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(registerControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ocupa2'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Crear cuenta', style: AppTypography.headlineLgMobile),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'Necesitas la matrícula de un estudiante del padrón como '
                    'código de referido.',
                    style: AppTypography.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Correo electrónico',
                    hint: 'persona@correo.com',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
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
                  AppTextField(
                    label: 'Matrícula de referido',
                    hint: '99999999',
                    controller: _matricula,
                    keyboardType: TextInputType.number,
                    validator: Validators.referralMatricula,
                    enabled: !loading,
                  ),
                  AppTextField(
                    label: 'Clave',
                    hint: 'Mínimo 6 caracteres',
                    controller: _password,
                    obscureText: true,
                    validator: Validators.password,
                    enabled: !loading,
                  ),
                  AppTextField(
                    label: 'Confirmar clave',
                    controller: _confirm,
                    obscureText: true,
                    enabled: !loading,
                    validator: (v) => Validators.confirmPassword(v, _password.text),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PrimaryButton(
                    label: 'Crear cuenta',
                    loading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
