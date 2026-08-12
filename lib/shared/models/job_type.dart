import '../../core/network/json.dart';
import 'custom_field.dart';

/// GET /job-types. Los tipos de empleo y sus campos personalizados NUNCA se
/// hardcodean: este modelo es la única fuente.
class JobType {
  const JobType({
    required this.key,
    required this.name,
    this.fields = const <CustomField>[],
  });

  final String key;
  final String name;
  final List<CustomField> fields;

  factory JobType.fromJson(JsonMap json) {
    final key = asString(pick(json, ['key', 'jobTypeKey', 'id', 'slug']));
    return JobType(
      key: key,
      name: asString(pick(json, ['name', 'label', 'title']), fallback: key),
      fields: asModelList(
        pick(json, ['fields', 'customFields', 'questions', 'schema']),
        CustomField.fromJson,
      ),
    );
  }
}
