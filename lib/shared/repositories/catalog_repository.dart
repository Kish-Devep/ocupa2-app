import '../../core/network/api_client.dart';
import '../models/job_type.dart';

/// GET /job-types. Única fuente de los tipos de empleo y de sus campos
/// personalizados. Nada de listas fijas en el código.
class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  Future<List<JobType>> jobTypes() => _client.get<List<JobType>>(
        '/job-types',
        parse: (data) => asModelListOfJobTypes(data),
      );
}

// Helper con nombre explícito para que el test lea bien.
List<JobType> asModelListOfJobTypes(dynamic data) {
  return _list(data);
}

List<JobType> _list(dynamic data) {
  final result = <JobType>[];
  if (data is List) {
    for (final item in data) {
      if (item is Map) {
        result.add(JobType.fromJson(Map<String, dynamic>.from(item)));
      }
    }
  }
  return result;
}
