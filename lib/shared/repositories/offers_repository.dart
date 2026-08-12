import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../models/offer.dart';
import '../models/offer_input.dart';

class OffersRepository {
  OffersRepository(this._client);

  final ApiClient _client;

  /// GET /offers — identidad del publicante oculta.
  Future<List<Offer>> explore({String? jobTypeKey, String? contractType}) =>
      _client.get<List<Offer>>(
        '/offers',
        query: <String, dynamic>{
          'jobTypeKey': jobTypeKey,
          'contractType': contractType,
        },
        parse: (data) => asModelList(data, Offer.fromJson),
      );

  /// GET /offers/{id} — el publicante solo viene poblado si soy el ganador.
  Future<Offer> detail(String id) => _client.get<Offer>(
        '/offers/$id',
        parse: (data) => Offer.fromJson(asMap(data)),
      );

  /// GET /me/offers
  Future<List<Offer>> myOffers() => _client.get<List<Offer>>(
        '/me/offers',
        parse: (data) => asModelList(data, Offer.fromJson),
      );

  /// POST /offers — body 1:1 con el schema `OfferInput`.
  Future<Offer> create(OfferInput input) => _client.post<Offer>(
        '/offers',
        body: input.toJson(),
        parse: (data) => Offer.fromJson(asMap(data)),
      );

  /// POST /offers/{id}/deactivate — solo dueño.
  Future<void> deactivate(String id) => _client.post<void>(
        '/offers/$id/deactivate',
        parse: (_) {},
      );

  /// POST /offers/{id}/like — idempotente, devuelve el total de likes.
  Future<int> like(String id) => _client.post<int>(
        '/offers/$id/like',
        parse: (data) => asInt(asMap(data)['likes']) ?? 0,
      );

  /// DELETE /offers/{id}/like
  Future<int> unlike(String id) => _client.delete<int>(
        '/offers/$id/like',
        parse: (data) => asInt(asMap(data)['likes']) ?? 0,
      );
}
