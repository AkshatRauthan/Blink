/// High-level state of a transfer session.
enum TransferStatus {
  pending,
  connecting,
  transferring,
  paused,
  completed,
  failed,
  cancelled,
}

/// Direction of the transfer from the local device's perspective.
enum TransferDirection { send, receive }

/// Represents one transfer session (may contain multiple files).
///
/// Stored in SQLite for transfer history and resume capability.
class TransferSession {
  final int? id;
  final String sessionId;
  final String remoteDeviceId;
  final TransferDirection direction;
  final TransferStatus status;
  final List<String> fileIds;
  final int totalBytes;
  final int transferredBytes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;

  const TransferSession({
    this.id,
    required this.sessionId,
    required this.remoteDeviceId,
    required this.direction,
    this.status = TransferStatus.pending,
    this.fileIds = const [],
    this.totalBytes = 0,
    this.transferredBytes = 0,
    this.startedAt,
    this.completedAt,
    this.failureReason,
  });

  /// Progress as a value between 0.0 and 1.0.
  double get progress =>
      totalBytes == 0 ? 0.0 : (transferredBytes / totalBytes).clamp(0.0, 1.0);

  TransferSession copyWith({
    int? id,
    String? sessionId,
    String? remoteDeviceId,
    TransferDirection? direction,
    TransferStatus? status,
    List<String>? fileIds,
    int? totalBytes,
    int? transferredBytes,
    DateTime? startedAt,
    DateTime? completedAt,
    String? failureReason,
  }) =>
      TransferSession(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        remoteDeviceId: remoteDeviceId ?? this.remoteDeviceId,
        direction: direction ?? this.direction,
        status: status ?? this.status,
        fileIds: fileIds ?? this.fileIds,
        totalBytes: totalBytes ?? this.totalBytes,
        transferredBytes: transferredBytes ?? this.transferredBytes,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        failureReason: failureReason ?? this.failureReason,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'remoteDeviceId': remoteDeviceId,
        'direction': direction.name,
        'status': status.name,
        'fileIds': fileIds,
        'totalBytes': totalBytes,
        'transferredBytes': transferredBytes,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'failureReason': failureReason,
      };

  factory TransferSession.fromJson(Map<String, dynamic> json) =>
      TransferSession(
        id: json['id'] as int?,
        sessionId: json['sessionId'] as String,
        remoteDeviceId: json['remoteDeviceId'] as String,
        direction: TransferDirection.values.firstWhere(
          (e) => e.name == json['direction'],
          orElse: () => TransferDirection.send,
        ),
        status: TransferStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransferStatus.pending,
        ),
        fileIds: (json['fileIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        totalBytes: json['totalBytes'] as int? ?? 0,
        transferredBytes: json['transferredBytes'] as int? ?? 0,
        startedAt: json['startedAt'] != null
            ? DateTime.tryParse(json['startedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        failureReason: json['failureReason'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferSession &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() =>
      'TransferSession(sessionId: $sessionId, status: ${status.name}, '
      'progress: ${(progress * 100).toStringAsFixed(1)}%)';
}
