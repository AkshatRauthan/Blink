import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../services/transfer/http_server_service.dart';

class ChatState {
  final String sessionId;
  final String remoteIp;
  final int remotePort;
  final List<ChatMessage> messages;

  const ChatState({
    this.sessionId = '',
    this.remoteIp = '',
    this.remotePort = 0,
    this.messages = const [],
  });

  ChatState copyWith({
    String? sessionId,
    String? remoteIp,
    int? remotePort,
    List<ChatMessage>? messages,
  }) =>
      ChatState(
        sessionId: sessionId ?? this.sessionId,
        remoteIp: remoteIp ?? this.remoteIp,
        remotePort: remotePort ?? this.remotePort,
        messages: messages ?? this.messages,
      );
}

class ChatNotifier extends Notifier<ChatState> {
  StreamSubscription<ChatMessage>? _incomingSub;

  @override
  ChatState build() {
    _incomingSub?.cancel();
    _incomingSub = HttpServerService.instance.onChatMessage.listen(_onReceived);
    ref.onDispose(() => _incomingSub?.cancel());
    return const ChatState();
  }

  void openSession({
    required String sessionId,
    required String remoteIp,
    required int remotePort,
  }) {
    state = state.copyWith(
      sessionId: sessionId,
      remoteIp: remoteIp,
      remotePort: remotePort,
    );
    _loadHistory(sessionId);
  }

  Future<void> _loadHistory(String sessionId) async {
    final history = await ChatRepository.instance.messagesForSession(sessionId);
    state = state.copyWith(messages: history);
  }

  void _onReceived(ChatMessage message) {
    if (state.sessionId.isNotEmpty && message.sessionId != state.sessionId) {
      return;
    }
    ChatRepository.instance.saveMessage(message);
    state = state.copyWith(messages: [...state.messages, message]);
  }

  Future<void> sendMessage(String text) async {
    final message = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: state.sessionId.isEmpty ? 'local' : state.sessionId,
      senderDeviceId: 'me',
      text: text,
      sentAt: DateTime.now(),
      isRead: true,
    );

    await ChatRepository.instance.saveMessage(message);
    state = state.copyWith(messages: [...state.messages, message]);

    if (state.remoteIp.isNotEmpty && state.sessionId.isNotEmpty) {
      _sendOverHttp(message);
    }
  }

  Future<void> _sendOverHttp(ChatMessage message) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final port =
          state.remotePort > 0 ? state.remotePort : AppConstants.transferPort;
      final uri = Uri.parse(
        'http://${state.remoteIp}:$port/transfer/${state.sessionId}/chat',
      );
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(message.toJson()));
      final response = await request.close();
      await response.drain<void>();
      client.close(force: true);
    } catch (e) {
      Log.w(
        'Chat send failed: $e',
        source: LogSource.network,
        component: 'ChatNotifier',
      );
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
