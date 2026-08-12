import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Slider del inicio: configuración local, sin API (módulo 9 del mandato).
class HomeSlide {
  const HomeSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
}

const List<HomeSlide> homeSlides = <HomeSlide>[
  HomeSlide(
    title: 'Encuentra tu próximo trabajo temporal',
    subtitle: 'Oportunidades flexibles a tu alcance.',
    icon: Icons.construction,
    background: AppColors.primaryContainer,
    foreground: Colors.white,
  ),
  HomeSlide(
    title: 'Conexión rápida',
    subtitle: 'Miles de oficios verificados te esperan.',
    icon: Icons.bolt,
    background: AppColors.secondaryContainer,
    foreground: AppColors.onSecondaryContainer,
  ),
  HomeSlide(
    title: 'Publica en minutos',
    subtitle: 'Sube una foto, paga 1 USD y recibe aplicantes.',
    icon: Icons.campaign_outlined,
    background: AppColors.tertiaryFixed,
    foreground: AppColors.tertiary,
  ),
];
