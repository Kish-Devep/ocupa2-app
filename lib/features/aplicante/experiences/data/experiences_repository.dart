import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/models/experience.dart';

class ExperiencesRepository {
  ExperiencesRepository(this._client);

  final ApiClient _client;

  /// GET /me/experiences
  Future<List<Experience>> list() => _client.get<List<Experience>>(
        '/me/experiences',
        parse: (data) => asModelList(data, Experience.fromJson),
      );

  /// POST /me/experiences — `{title*, description*, jobTypeKey?, certificateImage?}`
  /// `certificateImage` es la URL que devolvió POST /uploads.
  Future<Experience> add({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) =>
      _client.post<Experience>(
        '/me/experiences',
        body: <String, dynamic>{
          'title': title.trim(),
          'description': description.trim(),
          if (jobTypeKey != null && jobTypeKey.isNotEmpty) 'jobTypeKey': jobTypeKey,
          if (certificateImage != null && certificateImage.isNotEmpty)
            'certificateImage': certificateImage,
        },
        parse: (data) => Experience.fromJson(asMap(data)),
      );

  /// DELETE /me/experiences/{id}
  Future<void> remove(String id) => _client.delete<void>(
        '/me/experiences/$id',
        parse: (_) {},
      );
}

final experiencesRepositoryProvider = Provider<ExperiencesRepository>(
  (ref) => ExperiencesRepository(ref.watch(apiClientProvider)),
);
