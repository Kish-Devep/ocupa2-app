import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';
import '../models/job_type.dart';
import '../repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);

/// Cacheado durante toda la sesión: los tipos de empleo se usan en Explorar,
/// Publicar oferta, Experiencias y los filtros.
final jobTypesProvider = FutureProvider<List<JobType>>(
  (ref) => ref.watch(catalogRepositoryProvider).jobTypes(),
);

/// Búsqueda por key, para resolver el nombre legible de un `jobTypeKey`.
final jobTypeByKeyProvider = Provider.family<JobType?, String>((ref, key) {
  final types = ref.watch(jobTypesProvider).valueOrNull ?? const <JobType>[];
  for (final type in types) {
    if (type.key == key) return type;
  }
  return null;
});
