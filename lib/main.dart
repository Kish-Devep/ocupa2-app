import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await SystemChrome.setPreferredOrientations(
    const <DeviceOrientation>[DeviceOrientation.portraitUp],
  );
  runApp(const ProviderScope(child: Ocupa2App()));
}

