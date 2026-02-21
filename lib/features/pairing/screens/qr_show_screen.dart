import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/pairing_provider.dart';

class QrShowScreen extends ConsumerWidget {
  const QrShowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairingState = ref.watch(pairingNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Show QR Code')),
      body: Center(
        child: pairingState.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (qrString) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: qrString != null
                      ? QrImageView(
                          data: qrString,
                          version: QrVersions.auto,
                          size: 240,
                        )
                      : const SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ask the other device to scan this code'),
              const SizedBox(height: 8),
              // QR expires in 5 minutes — show a countdown
              // TODO: Add countdown timer widget
            ],
          ),
        ),
      ),
    );
  }
}
