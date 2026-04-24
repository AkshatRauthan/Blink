import '../../core/utils/logger.dart';

/// WebRTC-based fallback transport using [flutter_webrtc].
///
/// Used when:
/// - Devices are on different subnets (NAT traversal)
/// - User enables "Maximum Privacy" mode (no direct IP exchange)
///
/// This transport is NOT used for normal LAN transfers.
/// The primary path is always direct HTTP over LAN.
class WebRtcService {
  WebRtcService._();
  static final instance = WebRtcService._();

  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    // TODO: Import flutter_webrtc and initialise WebRTC stack
    // await WebRTC.initialize();
    _initialised = true;
    Log.i(
      'Service initialised',
      source: LogSource.network,
      component: 'WebRtcService',
    );
  }

  /// Creates a WebRTC peer connection with the given ICE configuration.
  Future<void> createPeerConnection(String remoteDeviceId) async {
    // TODO: Set up RTCPeerConnection with DataChannel for file streaming
    Log.d(
      'Creating peer connection to $remoteDeviceId',
      source: LogSource.network,
      component: 'WebRtcService',
    );
  }

  Future<void> dispose() async {
    _initialised = false;
  }
}
