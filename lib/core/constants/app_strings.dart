abstract class AppStrings {
  // ── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'Blink';
  static const String tagline = 'Share instantly. No internet. No login.';

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboardingTitle = 'Welcome to Blink';
  static const String onboardingSubtitle = 'Choose a name to get started';
  static const String onboardingNameHint = 'Your name';
  static const String onboardingContinue = 'Let\'s go';

  // ── Discovery ────────────────────────────────────────────────────────────
  static const String discoverySearching = 'Looking for nearby devices…';
  static const String discoveryNoDevices = 'No devices nearby';
  static const String discoveryTapToSend = 'Tap a device to send files';

  // ── Pairing ──────────────────────────────────────────────────────────────
  static const String pairingShowQr = 'Show QR Code';
  static const String pairingScanQr = 'Scan QR Code';
  static const String pairingInstructions =
      'Scan the other device\'s QR code to pair securely';
  static const String pairingSuccess = 'Paired successfully';
  static const String pairingExpired = 'QR code expired — please regenerate';
  static const String pairingInvalid = 'Invalid QR code';

  // ── Transfer ─────────────────────────────────────────────────────────────
  static const String transferSending = 'Sending…';
  static const String transferReceiving = 'Receiving…';
  static const String transferComplete = 'Transfer complete';
  static const String transferFailed = 'Transfer failed';
  static const String transferPaused = 'Paused';
  static const String transferCancelled = 'Cancelled';

  // ── Errors ───────────────────────────────────────────────────────────────
  static const String errorNetwork = 'Network error';
  static const String errorPermission = 'Permission denied';
  static const String errorUnknown = 'Something went wrong';
}
