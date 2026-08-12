import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/forgot_password_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _matricula = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    _matricula.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(forgotPasswordControllerProvider.notifier).submit(
          email: _email.text,
          referralMatricula: _matricula.text,
        );

    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      final error = ref.read(forgotPasswordControllerProvider).error;
      if (error != null) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(forgotPasswordControllerProvider).isLoading;

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
            constraints: const BoxConstraints(maxWidth: 480),
            child: _sent
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      const Icon(Icons.mark_email_read_outlined,
                          size: 56, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.md),
                      Text('Revisa tu correo',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineSm),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Si los datos coinciden, te enviamos una clave temporal. '
                        'Inicia sesión con ella y cámbiala desde tu perfil.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'Volver al inicio de sesión',
                        onPressed: () => context.pop(),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Recuperar clave',
                            style: AppTypography.headlineLgMobile),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          'Ingresa el correo y la matrícula de referido con la que '
                          'creaste la cuenta.',
                          style: AppTypography.bodyMd,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Correo electrónico',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          enabled: !loading,
                        ),
                        AppTextField(
                          label: 'Matrícula de referido',
                          hint: '99999999',
                          controller: _matricula,
                          keyboardType: TextInputType.number,
                          validator: Validators.referralMatricula,
                          enabled: !loading,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        PrimaryButton(
                          label: 'Enviar clave temporal',
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
