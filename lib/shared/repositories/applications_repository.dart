import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../../core/utils/date_formats.dart';
import '../models/application.dart';

class ApplicationsRepository {
  ApplicationsRepository(this._client);

  final ApiClient _client;

  /// POST /offers/{id}/apply — `{comment*, answers:[{questionId, value}]}`.
  /// 409 si ya aplicaste.
  Future<Application> apply({
    required String offerId,
    required String comment,
    List<Map<String, dynamic>> answers = const <Map<String, dynamic>>[],
  }) =>
      _client.post<Application>(
        '/offers/$offerId/apply',
        body: <String, dynamic>{
          'comment': comment,
          if (answers.isNotEmpty) 'answers': answers,
        },
        parse: (data) => Application.fromJson(asMap(data)),
      );

  /// GET /me/applications
  Future<List<Application>> mine() => _client.get<List<Application>>(
        '/me/applications',
        parse: (data) => asModelList(data, Application.fromJson),
      );

  /// GET /offers/{id}/applications — solo dueño (403 si no lo eres).
  Future<List<Application>> forOffer(String offerId) =>
      _client.get<List<Application>>(
        '/offers/$offerId/applications',
        parse: (data) => asModelList(data, Application.fromJson),
      );

  /// PATCH /applications/{id}. Con `status = winner` el backend crea el
  /// contrato automáticamente; los términos son opcionales.
  Future<Application> update(
    String applicationId, {
    int? rating,
    ApplicationStatus? status,
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) =>
      _client.patch<Application>(
        '/applications/$applicationId',
        body: <String, dynamic>{
          if (rating != null) 'rating': rating,
          if (status != null) 'status': status.apiValue,
          if (salary != null) 'salary': salary,
          if (currency != null) 'currency': currency,
          if (startDate != null) 'startDate': DateFormats.apiDate(startDate),
          if (duration != null && duration.trim().isNotEmpty) 'duration': duration,
        },
        parse: (data) => Application.fromJson(asMap(data)),
      );
}
