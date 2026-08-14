import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/application.dart';
import '../../../../shared/providers/applications_provider.dart';

class MyApplicationsController extends AsyncNotifier<List<Application>> {
  @override
  Future<List<Application>> build() =>
      ref.watch(applicationsRepositoryProvider).mine();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(applicationsRepositoryProvider).mine(),
    );
  }
}

final myApplicationsControllerProvider =
    AsyncNotifierProvider<MyApplicationsController, List<Application>>(
  MyApplicationsController.new,
);

final applicationsFilterProvider =
    StateProvider.autoDispose<ApplicationStatus?>((ref) => null);
