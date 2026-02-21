/// Per-file state within a TransferSession.
class TransferFile {
  final int? id;
  final String fileId;
  final String sessionId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final int transferredBytes;
  final bool completed;
  final String? localPath;
  final String? blake3Checksum;
  final String? failureReason;

  const TransferFile({
    this.id,
    required this.fileId,
    required this.sessionId,
    required this.fileName,
    this.mimeType = '',
    required this.sizeBytes,
    this.transferredBytes = 0,
    this.completed = false,
    this.localPath,
    this.blake3Checksum,
    this.failureReason,
  });

  /// Per-file progress 0.0 - 1.0.
  double get progress =>
      sizeBytes == 0 ? 0.0 : (transferredBytes / sizeBytes).clamp(0.0, 1.0);

  TransferFile copyWith({
    int? id,
    String? fileId,
    String? sessionId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    int? transferredBytes,
    bool? completed,
    String? localPath,
    String? blake3Checksum,
    String? failureReason,
  }) =>
      TransferFile(
        id: id ?? this.id,
        fileId: fileId ?? this.fileId,
        sessionId: sessionId ?? this.sessionId,
        fileName: fileName ?? this.fileName,
        mimeType: mimeType ?? this.mimeType,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        transferredBytes: transferredBytes ?? this.transferredBytes,
        completed: completed ?? this.completed,
        localPath: localPath ?? this.localPath,
        blake3Checksum: blake3Checksum ?? this.blake3Checksum,
        failureReason: failureReason ?? this.failureReason,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileId': fileId,
        'sessionId': sessionId,
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'transferredBytes': transferredBytes,
        'completed': completed,
        'localPath': localPath,
        'blake3Checksum': blake3Checksum,
        'failureReason': failureReason,
      };

  factory TransferFile.fromJson(Map<String, dynamic> json) => TransferFile(
        id: json['id'] as int?,
        fileId: json['fileId'] as String,
        sessionId: json['sessionId'] as String,
        fileName: json['fileName'] as String,
        mimeType: json['mimeType'] as String? ?? '',
        sizeBytes: json['sizeBytes'] as int? ?? 0,
        transferredBytes: json['transferredBytes'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        localPath: json['localPath'] as String?,
        blake3Checksum: json['blake3Checksum'] as String?,
        failureReason: json['failureReason'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferFile &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;
}
