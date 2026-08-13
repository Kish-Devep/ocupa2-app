import 'package:ocupa2/shared/models/application.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/models/job_type.dart';
import 'package:ocupa2/shared/models/offer.dart';
import 'package:ocupa2/shared/models/user.dart';

/// JSON tal como lo devuelve el API dentro de `data`.
const Map<String, dynamic> userJson = <String, dynamic>{
  'id': 'u1',
  'email': 'persona@correo.com',
  'firstName': 'Juan',
  'lastName': 'Pérez',
  'nombre': 'Juan Pérez',
  'cedula': '40212345678',
  'gender': 'masculino',
  'birthDate': '2004-05-17T00:00:00.000Z',
  'profileCompleted': true,
  'referralMatricula': '99999999',
  'role': 'user',
  'createdAt': '2026-01-10T10:00:00.000Z',
};

const Map<String, dynamic> sessionJson = <String, dynamic>{
  'token': 'jwt-de-prueba',
  'tokenType': 'Bearer',
  'user': userJson,
};

const Map<String, dynamic> offerJson = <String, dynamic>{
  'id': 'o1',
  'jobTypeKey': 'chofer',
  'jobTypeName': 'Chofer',
  'contractType': 'temporal',
  'description': 'Se necesita chofer para reparto en la zona colonial.',
  'address': 'Ensanche Naco, D.N.',
  'photo': 'https://cdn.ocupa2.test/foto.jpg',
  'location': <String, dynamic>{'lat': 18.4861, 'lng': -69.9312},
  'payment': <String, dynamic>{'amount': 2500, 'currency': 'DOP'},
  'deadline': '2026-08-30',
  'active': true,
  'applicationsCount': 3,
  'questions': <dynamic>[
    <String, dynamic>{
      'id': 'q1',
      'label': '¿Tienes licencia categoría 03?',
      'type': 'check',
      'required': true,
    },
  ],
};

const Map<String, dynamic> applicationJson = <String, dynamic>{
  'id': 'a1',
  'status': 'applied',
  'comment': 'Tengo 5 años de experiencia conduciendo.',
  'createdAt': '2026-08-09T12:00:00.000Z',
  'offer': offerJson,
  'applicant': userJson,
};

const List<Map<String, dynamic>> jobTypesJson = <Map<String, dynamic>>[
  <String, dynamic>{
    'key': 'chofer',
    'name': 'Chofer',
    'fields': <dynamic>[
      <String, dynamic>{
        'key': 'categoria_licencia',
        'label': 'Categoría de licencia',
        'type': 'select',
        'required': true,
        'options': <String>['01', '02', '03'],
      },
      <String, dynamic>{
        'key': 'anos_experiencia',
        'label': 'Años de experiencia',
        'type': 'number',
        'required': false,
      },
    ],
  },
];

User get testUser => User.fromJson(userJson);
Offer get testOffer => Offer.fromJson(offerJson);
Application get testApplication => Application.fromJson(applicationJson);
JobType get testJobType => JobType.fromJson(jobTypesJson.first);

const List<CustomField> allFieldTypes = <CustomField>[
  CustomField(key: 'nombre', label: 'Nombre completo', type: CustomFieldType.text),
  CustomField(key: 'anos', label: 'Años', type: CustomFieldType.number),
  CustomField(key: 'inicio', label: 'Fecha de inicio', type: CustomFieldType.date),
  CustomField(
    key: 'turno',
    label: 'Turno',
    type: CustomFieldType.select,
    options: <String>['Mañana', 'Tarde'],
  ),
  CustomField(key: 'acepto', label: 'Acepto los términos', type: CustomFieldType.check),
];

/// Respuesta real de GET /me/offers capturada el 12 de agosto de 2026,
/// usada para blindar el parseo de `status` y `applicantsCount` contra
/// los nombres de campo reales del API (ya no adivinados).
const Map<String, dynamic> realMyOfferJson = <String, dynamic>{
  'id': '6a7c9cca764be25e24064f0b',
  'ownerId': '6a7be7d0764be25e24064efd',
  'jobTypeKey': 'campo',
  'jobTypeName': 'Hacedor de tareas',
  'contractType': 'horas',
  'description': 'Debes tumbar todos los limoncillos del patio.',
  'address': 'Bonao',
  'location': <String, dynamic>{'lat': 0, 'lng': 0},
  'payment': <String, dynamic>{
    'amount': 150,
    'currency': 'DOP',
    'period': 'hora',
  },
  'photo': 'https://ocupa2.ia3x.com/media/foto.jpg',
  'deadline': '2026-08-31T00:00:00+00:00',
  'customAnswers': <String, dynamic>{'nivel': true},
  'questions': <dynamic>[],
  'status': 'published',
  'paymentId': 'pay-1',
  'applicantsCount': 1,
  'likesCount': 0,
  'createdAt': '2026-08-12T16:18:18+00:00',
  'updatedAt': '2026-08-12T16:18:18+00:00',
};
