import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Canal de eventos de sesión. Existe para que `core/` **no dependa de**
/// `features/`: el interceptor emite aquí y el `SessionController` escucha.
class AuthEvents {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get onUnauthorized => _controller.stream;

  void emitUnauthorized() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}

final authEventsProvider = Provider<AuthEvents>((ref) {
  final events = AuthEvents();
  ref.onDispose(events.dispose);
  return events;
});
