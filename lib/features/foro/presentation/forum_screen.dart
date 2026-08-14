import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/empty_view.dart';
import '../state/forum_topics_controller.dart';
import 'create_topic_sheet.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreateTopicSheet(),
    );
    if (result == null) return;
    try {
      await ref.read(forumTopicsControllerProvider.notifier).create(
            title: result.$1,
            description: result.$2,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(forumTopicsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Foro'),
        actions: [
          IconButton(
            key: const Key('create_topic'),
            onPressed: () => _create(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: AsyncView(
        value: topics,
        onRetry: () => ref.invalidate(forumTopicsControllerProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.forum_outlined,
              title: 'No hay temas todavía',
              message: 'Sé la primera persona en iniciar una conversación.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(forumTopicsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final topic = items[index];
                return Card(
                  child: ListTile(
                    key: Key('topic_${topic.id}'),
                    title: Text(topic.title, style: AppTypography.labelLg),
                    subtitle: Text(topic.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    leading: const Icon(Icons.forum_outlined),
                    trailing: Text('${topic.commentsCount}'),
                    onTap: () => context.push('/forum/${topic.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}