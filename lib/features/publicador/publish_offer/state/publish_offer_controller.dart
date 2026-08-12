import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/models/custom_field.dart';
import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/job_type.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/models/offer_input.dart';
import '../../../../shared/providers/offers_provider.dart';
import '../../../../shared/providers/upload_provider.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../my_offers/state/my_offers_controller.dart';
import '../../offers/state/explore_offers_controller.dart';
import '../../payments/data/payment_request.dart';
import '../../payments/data/payments_repository.dart';
import '../../payments/state/my_payments_controller.dart';

/// Estado del asistente. Es el único punto de la app con una máquina de
/// estados real, por eso aquí sí se modela explícitamente en vez de usar
/// un simple AsyncValue.
class PublishOfferState {
  const PublishOfferState({
    this.step = 0,
    this.jobType,
    this.contractType = ContractType.temporal,
    this.description = '',
    this.address = '',
    this.photo,
    this.location,
    this.deadline,
    this.amount,
    this.currency = 'DOP',
    this.customAnswers = const <String, dynamic>{},
    this.questions = const <OfferQuestionInput>[],
    this.submitting = false,
    this.paymentId,
    this.photoUrl,
    this.created,
    this.error,
  });

  final int step; // 0 detalles · 1 preguntas · 2 pago
  final JobType? jobType;
  final ContractType contractType;
  final String description;
  final String address;
  final PickedPhoto? photo;
  final GeoPoint? location;
  final DateTime? deadline;
  final double? amount;
  final String currency;
  final Map<String, dynamic> customAnswers;
  final List<OfferQuestionInput> questions;

  final bool submitting;

  /// Se conservan entre reintentos: si el pago pasó pero POST /offers falló,
  /// no se vuelve a cobrar ni a subir la imagen.
  final String? paymentId;
  final String? photoUrl;

  final Offer? created;
  final Object? error;

  List<CustomField> get jobTypeFields => jobType?.fields ?? const <CustomField>[];

  bool get detailsValid =>
      jobType != null &&
      description.trim().length >= 10 &&
      address.trim().length >= 3 &&
      photo != null &&
      (amount ?? 0) > 0;

  PublishOfferState copyWith({
    int? step,
    JobType? jobType,
    ContractType? contractType,
    String? description,
    String? address,
    PickedPhoto? photo,
    bool clearPhoto = false,
    GeoPoint? location,
    DateTime? deadline,
    double? amount,
    String? currency,
    Map<String, dynamic>? customAnswers,
    List<OfferQuestionInput>? questions,
    bool? submitting,
    String? paymentId,
    String? photoUrl,
    Offer? created,
    Object? error,
    bool clearError = false,
  }) =>
      PublishOfferState(
        step: step ?? this.step,
        jobType: jobType ?? this.jobType,
        contractType: contractType ?? this.contractType,
        description: description ?? this.description,
        address: address ?? this.address,
        photo: clearPhoto ? null : (photo ?? this.photo),
        location: location ?? this.location,
        deadline: deadline ?? this.deadline,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        customAnswers: customAnswers ?? this.customAnswers,
        questions: questions ?? this.questions,
        submitting: submitting ?? this.submitting,
        paymentId: paymentId ?? this.paymentId,
        photoUrl: photoUrl ?? this.photoUrl,
        created: created ?? this.created,
        error: clearError ? null : (error ?? this.error),
      );
}

class PublishOfferController extends AutoDisposeNotifier<PublishOfferState> {
  @override
  PublishOfferState build() => const PublishOfferState();

  void goTo(int step) => state = state.copyWith(step: step, clearError: true);

  void setJobType(JobType? jobType) =>
      state = state.copyWith(jobType: jobType, customAnswers: <String, dynamic>{});

  void setContractType(ContractType type) =>
      state = state.copyWith(contractType: type);

  void setDescription(String value) => state = state.copyWith(description: value);

  void setAddress(String value) => state = state.copyWith(address: value);

  void setPhoto(PickedPhoto? photo) => photo == null
      ? state = state.copyWith(clearPhoto: true)
      : state = state.copyWith(photo: photo);

  void setLocation(GeoPoint point) => state = state.copyWith(location: point);

  void setDeadline(DateTime date) => state = state.copyWith(deadline: date);

  void setAmount(double? amount) => state = state.copyWith(amount: amount);

  void setCurrency(String currency) => state = state.copyWith(currency: currency);

  void setCustomAnswers(Map<String, dynamic> answers) =>
      state = state.copyWith(customAnswers: answers);

  void addQuestion(OfferQuestionInput question) => state = state.copyWith(
        questions: [...state.questions, question],
      );

  void removeQuestion(int index) {
    final next = [...state.questions]..removeAt(index);
    state = state.copyWith(questions: next);
  }

  /// Flujo completo del módulo 14, en el orden que exige el API:
  ///   a) POST /uploads   → url de la foto (obligatoria)
  ///   b) POST /payments  → paymentId aprobado (402 si la tarjeta es rechazada)
  ///   c) POST /offers    → OfferInput completo
  ///
  /// Si (c) falla, los resultados de (a) y (b) se conservan en el estado para
  /// que reintentar no vuelva a cobrar.
  Future<bool> payAndPublish(PaymentRequest card) async {
    if (!state.detailsValid) {
      state = state.copyWith(
        error: const ApiException(
          kind: ApiErrorKind.validation,
          message: 'Faltan datos obligatorios de la oferta.',
        ),
      );
      return false;
    }

    state = state.copyWith(submitting: true, clearError: true);

    try {
      // a) Foto obligatoria.
      var photoUrl = state.photoUrl;
      if (photoUrl == null) {
        final upload = await ref.read(uploadRepositoryProvider).uploadImage(
              bytes: state.photo!.bytes,
              filename: state.photo!.filename,
            );
        photoUrl = upload.url;
        state = state.copyWith(photoUrl: photoUrl);
      }

      // b) Cobro simulado de 1 USD.
      var paymentId = state.paymentId;
      if (paymentId == null) {
        final payment = await ref.read(paymentsRepositoryProvider).charge(card);
        paymentId = payment.id;
        state = state.copyWith(paymentId: paymentId);
      }

      // c) Publicación.
      final input = OfferInput(
        jobTypeKey: state.jobType!.key,
        contractType: state.contractType,
        description: state.description.trim(),
        address: state.address.trim(),
        photo: photoUrl,
        paymentId: paymentId,
        payment: OfferPayment(amount: state.amount, currency: state.currency),
        location: state.location,
        deadline: state.deadline,
        customAnswers: state.customAnswers,
        questions: state.questions,
      );

      final offer = await ref.read(offersRepositoryProvider).create(input);

      // Las listas dependientes quedan obsoletas.
      ref.invalidate(myOffersControllerProvider);
      ref.invalidate(exploreOffersProvider);
      ref.invalidate(myPaymentsProvider);

      state = state.copyWith(submitting: false, created: offer, step: 3);
      return true;
    } on ApiException catch (error) {
      final mapped = switch (error.kind) {
        ApiErrorKind.paymentRequired => const ApiException(
            kind: ApiErrorKind.paymentRequired,
            statusCode: 402,
            message: 'La tarjeta fue rechazada. Verifica los datos e '
                'intenta con otra.',
          ),
        ApiErrorKind.validation => const ApiException(
            kind: ApiErrorKind.validation,
            statusCode: 422,
            message: 'Datos inválidos. Verifica que la foto se haya subido '
                'correctamente.',
          ),
        _ => error,
      };
      state = state.copyWith(submitting: false, error: mapped);
      return false;
    }
  }
}

final publishOfferControllerProvider =
    AutoDisposeNotifierProvider<PublishOfferController, PublishOfferState>(
  PublishOfferController.new,
);
