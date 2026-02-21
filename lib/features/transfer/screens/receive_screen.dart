import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Receiving')),
      body: sessions.isEmpty
          ? const Center(child: Text('Waiting for incoming files…'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (_, i) => TransferCard(session: sessions[i]),
            ),
    );
  }
}
