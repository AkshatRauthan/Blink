import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/isar_service.dart';
import 'services/security/key_store_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SQLite database before the widget tree mounts
  await IsarService.instance.init();

  // Ensure the device has an Ed25519 identity keypair stored
  await KeyStoreService.instance.ensureIdentityKey();

  runApp(
    // ProviderScope is the root of all Riverpod state
    const ProviderScope(
      child: BlinkApp(),
    ),
  );
}

