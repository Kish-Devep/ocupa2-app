import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Módulo 7 — sin API. Datos del equipo para la defensa.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<
      ({
        String name,
        String matricula,
        String role,
        String detail,
        String phone,
        String? telegram,
        String photoAsset,
      })> _team = [
    (
      name: 'Yafreilis Cuevas Santana',
      matricula: '2022-0656',
      role: 'Área A · Usuario y Aplicantes',
      detail: 'Autenticación, perfil, experiencias, aplicaciones y '
          'formulario dinámico.',
      phone: '8294058785',
      telegram: null,
      photoAsset: 'assets/team/yafreilis.jpg',
    ),
    (
      name: 'Manuel José Mella Montalvo',
      matricula: '2024-1662',
      role: 'Área B · Ofertas y Publicación',
      detail: 'Exploración, mapa, publicación con pago, gestión de '
          'aplicantes y contratos.',
      phone: '8499154266',
      telegram: 'Welinton024',
      photoAsset: 'assets/team/manuel.jpg',
    ),
  ];

  Future<void> _launchCall(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar la llamada')),
      );
    }
  }

  Future<void> _launchTelegram(BuildContext context, String username) async {
    final uri = Uri.parse('https://t.me/$username');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Telegram')),
      );
    }
  }

  String _formatPhone(String phone) {
    // 8294058785 -> 829-405-8785
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Acerca de'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ocupa2',
                    style: AppTypography.headlineLgMobile
                        .copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Plataforma de trabajos temporales que conecta a quien '
                  'necesita una mano con quien está buscando una oportunidad.',
                  style: AppTypography.bodyLg.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Equipo', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.xs),
          for (final member in _team)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: AppColors.primaryContainer,
                            child: ClipOval(
                              child: Image.asset(
                                member.photoAsset,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    _initials(member.name),
                                    style: AppTypography.headlineSm
                                        .copyWith(color: Colors.white),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.name,
                                    style: AppTypography.labelLg),
                                Text('Matrícula: ${member.matricula}',
                                    style: AppTypography.bodyMd),
                                Text(member.role,
                                    style: AppTypography.labelMd
                                        .copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(member.detail, style: AppTypography.bodyMd),
                      const SizedBox(height: AppSpacing.base),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _launchCall(context, member.phone),
                            icon: const Icon(Icons.call, size: 18),
                            label: Text(_formatPhone(member.phone)),
                          ),
                          if (member.telegram != null)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _launchTelegram(context, member.telegram!),
                              icon: const Icon(Icons.send, size: 18),
                              label: Text('@${member.telegram}'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text('Información técnica', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.xs),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API: ${ApiConfig.baseUrl}', style: AppTypography.bodyMd),
                  const SizedBox(height: AppSpacing.base),
                  Text('Flutter · Riverpod · Dio · go_router',
                      style: AppTypography.bodyMd),
                  const SizedBox(height: AppSpacing.base),
                  Text('Versión 1.0.0', style: AppTypography.labelMd),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}