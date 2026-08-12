import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/video.dart';
import '../data/videos_repository.dart';

final videosProvider = FutureProvider.autoDispose<List<Video>>(
  (ref) => ref.watch(videosRepositoryProvider).list(),
);
