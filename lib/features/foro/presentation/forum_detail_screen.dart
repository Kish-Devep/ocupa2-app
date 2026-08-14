import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/async_view.dart';
import '../state/forum_detail_controller.dart';

class ForumDetailScreen extends ConsumerStatefulWidget {
  const ForumDetailScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends ConsumerState<ForumDetailScreen> {
  final body = TextEditingController();

  @override
  void dispose() {
    body.dispose();
    super.dispose();
  }

  Future<void> comment() async {
    if (body.text.trim().isEmpty) return;
    await ref
        .read(forumDetailControllerProvider(widget.topicId).notifier)
        .addComment(body.text);
    body.clear();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(forumDetailControllerProvider(widget.topicId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Tema'),
      ),
      body: AsyncView(
        value: detail,
        onRetry: () => ref.invalidate(forumDetailControllerProvider(widget.topicId)),
        data: (topic) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                children: [
                  Text(topic.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(topic.description),
                  const Divider(height: 32),
                  for (final item in topic.comments)
                    Card(
                      child: ListTile(
                        title: Text(item.body),
                        subtitle: Text(item.author.nombre),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('comment_body'),
                        controller: body,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario',
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('send_comment'),
                      onPressed: comment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}