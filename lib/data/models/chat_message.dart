/// A single chat message exchanged during (or alongside) a transfer session.
class ChatMessage {
  final int? id;
  final String messageId;
  final String sessionId;
  final String senderDeviceId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    this.id,
    required this.messageId,
    required this.sessionId,
    required this.senderDeviceId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  ChatMessage copyWith({
    int? id,
    String? messageId,
    String? sessionId,
    String? senderDeviceId,
    String? text,
    DateTime? sentAt,
    bool? isRead,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        sessionId: sessionId ?? this.sessionId,
        senderDeviceId: senderDeviceId ?? this.senderDeviceId,
        text: text ?? this.text,
        sentAt: sentAt ?? this.sentAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'messageId': messageId,
        'sessionId': sessionId,
        'senderDeviceId': senderDeviceId,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int?,
        messageId: json['messageId'] as String,
        sessionId: json['sessionId'] as String,
        senderDeviceId: json['senderDeviceId'] as String,
        text: json['text'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId;

  @override
  int get hashCode => messageId.hashCode;
}
