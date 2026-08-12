import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/repositories/catalog_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  test('GET /job-types trae los tipos con sus campos personalizados', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/job-types', data: jobTypesJson),
    ]);

    final types = await CatalogRepository(api.client).jobTypes();

    expect(types, hasLength(1));
    expect(types.first.key, 'chofer');
    expect(types.first.fields, hasLength(2));
    expect(types.first.fields.first.type, CustomFieldType.select);
    expect(types.first.fields.first.options, <String>['01', '02', '03']);
    expect(types.first.fields.first.required, isTrue);
    expect(types.first.fields[1].type, CustomFieldType.number);
  });

  test('devuelve lista vacía si el API responde algo inesperado', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/job-types', data: null),
    ]);

    expect(await CatalogRepository(api.client).jobTypes(), isEmpty);
  });
}
