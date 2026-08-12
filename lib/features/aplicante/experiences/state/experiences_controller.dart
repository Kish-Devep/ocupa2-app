import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/experience.dart';
import '../../../../shared/providers/upload_provider.dart';
import '../data/experiences_repository.dart';

class ExperiencesController extends AsyncNotifier<List<Experience>> {
  @override
  Future<List<Experience>> build() =>
      ref.watch(experiencesRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncLoading<List<Experience>>();
    state = await AsyncValue.guard(
      () => ref.read(experiencesRepositoryProvider).list(),
    );
  }

  /// Flujo completo del módulo 4: si hay certificado, primero POST /uploads y
  /// luego se manda la URL resultante en `certificateImage`.
  Future<void> add({
    required String title,
    required String description,
    String? jobTypeKey,
    Uint8List? certificateBytes,
    String? certificateFilename,
  }) async {
    String? certificateUrl;
    if (certificateBytes != null && certificateFilename != null) {
      final upload = await ref.read(uploadRepositoryProvider).uploadImage(
            bytes: certificateBytes,
            filename: certificateFilename,
          );
      certificateUrl = upload.url;
    }

    final created = await ref.read(experiencesRepositoryProvider).add(
          title: title,
          description: description,
          jobTypeKey: jobTypeKey,
          certificateImage: certificateUrl,
        );

    // Actualización optimista sin refetch completo.
    final current = state.valueOrNull ?? const <Experience>[];
    state = AsyncData<List<Experience>>([created, ...current]);
  }

  Future<void> remove(String id) async {
    await ref.read(experiencesRepositoryProvider).remove(id);
    final current = state.valueOrNull ?? const <Experience>[];
    state = AsyncData<List<Experience>>(
      current.where((e) => e.id != id).toList(growable: false),
    );
  }
}

final experiencesControllerProvider =
    AsyncNotifierProvider<ExperiencesController, List<Experience>>(
  ExperiencesController.new,
);
