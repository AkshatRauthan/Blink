/// Base class for all typed exceptions thrown within Blink.
sealed class BlinkException implements Exception {
  final String message;
  final Object? cause;

  const BlinkException(this.message, {this.cause});

  @override
  String toString() => 'BlinkException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

// ── Network Errors ────────────────────────────────────────────────────────────

final class NetworkException extends BlinkException {
  const NetworkException(super.message, {super.cause});
}

final class ConnectionRefusedException extends NetworkException {
  const ConnectionRefusedException(String host, int port)
      : super('Connection refused to $host:$port');
}

// ── Transfer Errors ───────────────────────────────────────────────────────────

final class TransferException extends BlinkException {
  const TransferException(super.message, {super.cause});
}

final class TransferAbortedException extends TransferException {
  const TransferAbortedException() : super('Transfer aborted by remote peer');
}

final class ChecksumMismatchException extends TransferException {
  const ChecksumMismatchException(String filename)
      : super('BLAKE3 checksum mismatch for file: $filename');
}

// ── Security / Pairing Errors ─────────────────────────────────────────────────

final class SecurityException extends BlinkException {
  const SecurityException(super.message, {super.cause});
}

final class QrTokenExpiredException extends SecurityException {
  const QrTokenExpiredException() : super('QR token has expired');
}

final class QrTokenInvalidException extends SecurityException {
  const QrTokenInvalidException() : super('QR token signature is invalid');
}

final class KeyStoreException extends SecurityException {
  const KeyStoreException(super.message, {super.cause});
}

// ── Discovery Errors ──────────────────────────────────────────────────────────

final class DiscoveryException extends BlinkException {
  const DiscoveryException(super.message, {super.cause});
}
