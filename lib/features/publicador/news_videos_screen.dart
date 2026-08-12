import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'news/presentation/news_tab.dart';
import 'videos/presentation/videos_tab.dart';

/// Módulos 10 y 11 en una pantalla con pestañas, como en el mockup.
/// Cada pestaña tiene su propio repositorio y provider: son módulos separados
/// aunque compartan contenedor visual.
class NewsVideosScreen extends StatelessWidget {
  const NewsVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Noticias y videos'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            labelStyle: AppTypography.labelLg,
            tabs: const [
              Tab(text: 'Noticias'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.only(top: AppSpacing.base),
          child: TabBarView(children: [NewsTab(), VideosTab()]),
        ),
      ),
    );
  }
}
