import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_card.dart';

class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeTransfersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Sending')),
      body: sessions.isEmpty
          ? const Center(child: Text('No active transfers'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (_, i) => TransferCard(session: sessions[i]),
            ),
    );
  }
}
