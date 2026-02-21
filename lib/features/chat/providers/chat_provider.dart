import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [];

  Future<void> sendMessage(String text) async {
    // TODO: Send message over the active TCP connection alongside file transfer
    // For now, store locally
    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: 'current', // TODO: Pass active sessionId
      senderDeviceId: 'me',
      text: text,
      sentAt: DateTime.now(),
      isRead: true,
    );
    await ChatRepository.instance.saveMessage(message);
    state = [...state, message];
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
