import '../../core/network/api_client.dart';
import '../../core/network/json.dart';
import '../models/like_result.dart';
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

  /// GET /me/likes
  Future<List<Offer>> myLikes() => _client.get<List<Offer>>(
        '/me/likes',
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

  /// POST /offers/{id}/like — devuelve el objeto LikeResult
  Future<LikeResult> like(String id) => _client.post<LikeResult>(
        '/offers/$id/like',
        parse: (data) => LikeResult.fromJson(asMap(data)),
      );

  /// DELETE /offers/{id}/like — devuelve el objeto LikeResult
  Future<LikeResult> unlike(String id) => _client.delete<LikeResult>(
        '/offers/$id/like',
        parse: (data) => LikeResult.fromJson(asMap(data)),
      );
}