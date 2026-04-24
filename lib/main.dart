import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'data/local/isar_service.dart';
import 'services/security/key_store_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Log.init();
  Log.i(
    'Application bootstrap started',
    source: LogSource.process,
    component: 'Main',
  );

  FlutterError.onError = (details) {
    Log.e(
      'Flutter framework error',
      source: LogSource.process,
      component: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Initialise SQLite database before the widget tree mounts
  await IsarService.instance.init();

  // Ensure the device has an Ed25519 identity keypair stored
  await KeyStoreService.instance.ensureIdentityKey();

  runZonedGuarded(
    () {
      runApp(
        // ProviderScope is the root of all Riverpod state
        const ProviderScope(
          child: BlinkApp(),
        ),
      );
    },
    (error, stackTrace) {
      Log.f(
        'Uncaught zone error',
        source: LogSource.process,
        component: 'Zone',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );

  Log.i(
    'Application bootstrap completed',
    source: LogSource.process,
    component: 'Main',
  );

  // Best-effort flush on graceful termination.
  ProcessSignal.sigterm.watch().listen((_) async {
    Log.w(
      'SIGTERM received, closing logger sink',
      source: LogSource.process,
      component: 'Signal',
    );
    await Log.close();
  });
}

