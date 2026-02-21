/// Platform a discovered device is running on.
enum DevicePlatform { android, linux, windows, unknown }

/// A Blink device discovered on the local network.
///
/// Stored in SQLite for persistent contact history.
/// The [publicKeyBase64] holds the Ed25519 identity public key
/// received during the QR handshake.
class Device {
  final int? id;
  final String deviceId;
  final String name;
  final String publicKeyBase64;
  final DevicePlatform platform;
  final String? lastKnownIp;
  final int? lastKnownPort;
  final bool isFavourite;
  final DateTime? lastSeenAt;

  const Device({
    this.id,
    required this.deviceId,
    required this.name,
    this.publicKeyBase64 = '',
    required this.platform,
    this.lastKnownIp,
    this.lastKnownPort,
    this.isFavourite = false,
    this.lastSeenAt,
  });

  Device copyWith({
    int? id,
    String? deviceId,
    String? name,
    String? publicKeyBase64,
    DevicePlatform? platform,
    String? lastKnownIp,
    int? lastKnownPort,
    bool? isFavourite,
    DateTime? lastSeenAt,
  }) =>
      Device(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        name: name ?? this.name,
        publicKeyBase64: publicKeyBase64 ?? this.publicKeyBase64,
        platform: platform ?? this.platform,
        lastKnownIp: lastKnownIp ?? this.lastKnownIp,
        lastKnownPort: lastKnownPort ?? this.lastKnownPort,
        isFavourite: isFavourite ?? this.isFavourite,
        lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'name': name,
        'publicKeyBase64': publicKeyBase64,
        'platform': platform.name,
        'lastKnownIp': lastKnownIp,
        'lastKnownPort': lastKnownPort,
        'isFavourite': isFavourite,
        'lastSeenAt': lastSeenAt?.toIso8601String(),
      };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as int?,
        deviceId: json['deviceId'] as String,
        name: json['name'] as String,
        publicKeyBase64: json['publicKeyBase64'] as String? ?? '',
        platform: DevicePlatform.values.firstWhere(
          (e) => e.name == json['platform'],
          orElse: () => DevicePlatform.unknown,
        ),
        lastKnownIp: json['lastKnownIp'] as String?,
        lastKnownPort: json['lastKnownPort'] as int?,
        isFavourite: json['isFavourite'] as bool? ?? false,
        lastSeenAt: json['lastSeenAt'] != null
            ? DateTime.tryParse(json['lastSeenAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;

  @override
  String toString() =>
      'Device(deviceId: $deviceId, name: $name, platform: ${platform.name})';
}
