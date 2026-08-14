import 'package:flutter/material.dart';

class CreateTopicSheet extends StatefulWidget {
  const CreateTopicSheet({super.key});

  @override
  State<CreateTopicSheet> createState() => _CreateTopicSheetState();
}

class _CreateTopicSheetState extends State<CreateTopicSheet> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void submit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, (title.text.trim(), description.text.trim()));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nuevo tema', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('topic_title'),
                controller: title,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'El título es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('topic_description'),
                controller: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'La descripción es obligatoria' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('save_topic'),
                onPressed: submit,
                child: const Text('Publicar tema'),
              ),
            ],
          ),
        ),
      );
}