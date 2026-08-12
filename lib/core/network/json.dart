/// Helpers de parseo tolerante. El spec documenta los *request bodies* con
/// precisión pero deja varios *response schemas* como `object` genérico, así que
/// todo `fromJson` degrada con elegancia en lugar de lanzar excepciones.
typedef JsonMap = Map<String, dynamic>;

JsonMap asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

/// Convierte cualquier payload de lista en `List<T>`.
/// Acepta tanto `[...]` como `{"items": [...]}` o `{"results": [...]}`.
List<T> asModelList<T>(dynamic value, T Function(JsonMap json) fromJson) {
  final Iterable<dynamic> raw;
  if (value is List) {
    raw = value;
  } else if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final candidate = map['items'] ?? map['results'] ?? map['list'] ?? map['data'];
    raw = candidate is List ? candidate : const <dynamic>[];
  } else {
    raw = const <dynamic>[];
  }
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((e) => fromJson(Map<String, dynamic>.from(e)))
      .toList(growable: false);
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final s = value.toString();
  return s.isEmpty ? fallback : s;
}

String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

double? asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', ''));
  return null;
}

int? asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return fallback;
}

DateTime? asDate(dynamic value) {
  if (value is DateTime) return value;
  final s = asStringOrNull(value);
  if (s == null) return null;
  return DateTime.tryParse(s);
}

List<String> asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }
  return const <String>[];
}

/// Devuelve el primer valor no nulo entre varias claves candidatas.
/// El backend mezcla nomenclatura en español e inglés en algunas respuestas.
dynamic pick(JsonMap json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) return value;
  }
  return null;
}
