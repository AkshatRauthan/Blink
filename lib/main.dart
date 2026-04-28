import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'data/local/isar_service.dart';
import 'services/security/key_store_service.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Log.init();
      Log.i(
        'Application bootstrap started',
        source: LogSource.process,
        component: 'Main',
      );

      FlutterError.onError = (details) {
        Log.e(
          'Flutter framework error: ${details.exception}',
          source: LogSource.process,
          component: 'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      await IsarService.instance.init();
      await KeyStoreService.instance.ensureIdentityKey();

      runApp(
        const ProviderScope(
          child: BlinkApp(),
        ),
      );

      Log.i(
        'Application bootstrap completed',
        source: LogSource.process,
        component: 'Main',
      );

      ProcessSignal.sigterm.watch().listen((_) async {
        Log.w(
          'SIGTERM received, closing logger sink',
          source: LogSource.process,
          component: 'Signal',
        );
        await Log.close();
      });
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
}
