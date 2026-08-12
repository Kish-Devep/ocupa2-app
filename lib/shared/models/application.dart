import '../../core/network/json.dart';
import 'offer.dart';
import 'user.dart';

/// Estados documentados en `PATCH /applications/{id}`.
enum ApplicationStatus {
  applied,
  discarded,
  finalist,
  winner;

  static ApplicationStatus parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'discarded':
        return ApplicationStatus.discarded;
      case 'finalist':
        return ApplicationStatus.finalist;
      case 'winner':
        return ApplicationStatus.winner;
      case 'applied':
      default:
        return ApplicationStatus.applied;
    }
  }

  String get apiValue => name;

  /// Etiquetas en español exactamente como en los mockups.
  String get label => switch (this) {
        ApplicationStatus.applied => 'En revisión',
        ApplicationStatus.discarded => 'Descartado',
        ApplicationStatus.finalist => 'Finalista',
        ApplicationStatus.winner => 'Ganador',
      };
}

class ApplicationAnswer {
  const ApplicationAnswer({required this.questionId, required this.value});

  final String questionId;
  final dynamic value;

  factory ApplicationAnswer.fromJson(JsonMap json) => ApplicationAnswer(
        questionId: asString(pick(json, ['questionId', 'key', 'id'])),
        value: json['value'],
      );

  JsonMap toJson() => <String, dynamic>{
        'questionId': questionId,
        'value': value,
      };
}

class Application {
  const Application({
    required this.id,
    required this.status,
    this.offerId,
    this.offer,
    this.applicant,
    this.comment,
    this.answers = const <ApplicationAnswer>[],
    this.rating,
    this.createdAt,
  });

  final String id;
  final ApplicationStatus status;
  final String? offerId;

  /// Presente en GET /me/applications (la oferta a la que apliqué).
  final Offer? offer;

  /// Presente en GET /offers/{id}/applications (identidad del aplicante,
  /// visible solo para el dueño de la oferta).
  final User? applicant;

  final String? comment;
  final List<ApplicationAnswer> answers;
  final int? rating;
  final DateTime? createdAt;

  factory Application.fromJson(JsonMap json) {
    final offerJson = pick(json, ['offer', 'oferta']);
    final applicantJson = pick(json, ['applicant', 'user', 'aplicante', 'candidate']);
    return Application(
      id: asString(pick(json, ['id', '_id', 'applicationId'])),
      status: ApplicationStatus.parse(asStringOrNull(json['status'])),
      offerId: asStringOrNull(pick(json, ['offerId', 'offer_id'])) ??
          (offerJson is Map ? asStringOrNull(asMap(offerJson)['id']) : null),
      offer: offerJson is Map ? Offer.fromJson(asMap(offerJson)) : null,
      applicant: applicantJson is Map ? User.fromJson(asMap(applicantJson)) : null,
      comment: asStringOrNull(json['comment']),
      answers: asModelList(json['answers'], ApplicationAnswer.fromJson),
      rating: asInt(json['rating']),
      createdAt: asDate(pick(json, ['createdAt', 'appliedAt'])),
    );
  }
}
