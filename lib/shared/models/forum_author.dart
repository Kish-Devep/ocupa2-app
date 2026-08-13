import '../../core/network/json.dart';

class ForumAuthor {
  const ForumAuthor({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory ForumAuthor.fromJson(JsonMap json) => ForumAuthor(
        id: asString(json['id']),
        nombre: asString(json['nombre']),
      );
}