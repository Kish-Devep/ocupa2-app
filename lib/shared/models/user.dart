import '../../core/network/json.dart';

enum Gender {
  masculino,
  femenino,
  otro;

  static Gender? parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'masculino':
        return Gender.masculino;
      case 'femenino':
        return Gender.femenino;
      case 'otro':
        return Gender.otro;
      default:
        return null;
    }
  }

  String get label => switch (this) {
        Gender.masculino => 'Hombre',
        Gender.femenino => 'Mujer',
        Gender.otro => 'Otro',
      };

  /// Valor exacto que exige el enum del schema.
  String get apiValue => name;
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.profileCompleted,
    this.firstName,
    this.lastName,
    this.nombre,
    this.cedula,
    this.gender,
    this.birthDate,
    this.referralMatricula,
    this.role,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? nombre;
  final String? cedula;
  final Gender? gender;
  final DateTime? birthDate;
  final bool profileCompleted;
  final String? referralMatricula;
  final String? role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  factory User.fromJson(JsonMap json) => User(
        id: asString(pick(json, ['id', '_id', 'userId'])),
        email: asString(json['email']),
        firstName: asStringOrNull(json['firstName']),
        lastName: asStringOrNull(json['lastName']),
        nombre: asStringOrNull(json['nombre']),
        cedula: asStringOrNull(json['cedula']),
        gender: Gender.parse(asStringOrNull(json['gender'])),
        birthDate: asDate(json['birthDate']),
        profileCompleted: asBool(json['profileCompleted']),
        referralMatricula: asStringOrNull(json['referralMatricula']),
        role: asStringOrNull(json['role']),
        createdAt: asDate(json['createdAt']),
        lastLoginAt: asDate(json['lastLoginAt']),
      );

  String get displayName {
    final full = nombre?.trim();
    if (full != null && full.isNotEmpty) return full;
    final joined = [firstName, lastName]
        .where((e) => e != null && e.trim().isNotEmpty)
        .join(' ')
        .trim();
    return joined.isEmpty ? email : joined;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
