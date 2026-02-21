/// Central place for all compile-time constants used across Blink.
/// Change port / chunk size here and it propagates everywhere.
abstract class AppConstants {
  // ── Network ──────────────────────────────────────────────────────────────
  /// TCP port the embedded Shelf server listens on.
  static const int transferPort = 49876;

  /// mDNS service type advertised by Blink.
  static const String mdnsServiceType = '_blink._tcp';

  /// Human-readable mDNS service name prefix (suffixed with device name).
  static const String mdnsServiceName = 'Blink';

  // ── Transfer ─────────────────────────────────────────────────────────────
  /// Size of each encrypted file chunk in bytes (4 MB).
  static const int chunkSizeBytes = 4 * 1024 * 1024;

  /// Maximum number of files transferring simultaneously per session.
  static const int maxConcurrentTransfers = 4;

  /// HTTP connection keep-alive timeout.
  static const Duration httpKeepAlive = Duration(seconds: 30);

  // ── Security ─────────────────────────────────────────────────────────────
  /// QR token time-to-live (single-use after acceptance or on expiry).
  static const Duration qrTokenTtl = Duration(minutes: 5);

  /// Secure storage key for Ed25519 identity keypair.
  static const String identityKeyStoreKey = 'blink_identity_keypair';

  // ── BLE ──────────────────────────────────────────────────────────────────
  /// BLE service UUID advertised for Blink presence beacons.
  static const String bleServiceUuid = '0000FE01-0000-1000-8000-00805F9B34FB';

  /// Active scan window duration (battery duty-cycle).
  static const Duration bleScanWindow = Duration(seconds: 2);

  /// Gap between BLE scan bursts.
  static const Duration bleScanGap = Duration(seconds: 8);

  // ── UI ───────────────────────────────────────────────────────────────────
  /// Maximum UI progress stream updates per second.
  static const int progressUpdateFps = 60;
}
