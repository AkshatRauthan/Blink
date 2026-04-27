import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum BlinkAnimationType { loading, success, error }

class BlinkAnimation extends StatelessWidget {
  final BlinkAnimationType type;
  final double size;
  final bool repeat;

  const BlinkAnimation({
    super.key,
    required this.type,
    this.size = 120,
    bool? repeat,
  }) : repeat = repeat ?? (type == BlinkAnimationType.loading);

  String get _assetPath => switch (type) {
    BlinkAnimationType.loading => 'assets/lottie/loading.json',
    BlinkAnimationType.success => 'assets/lottie/success.json',
    BlinkAnimationType.error => 'assets/lottie/error.json',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        _assetPath,
        width: size,
        height: size,
        repeat: repeat,
        frameRate: FrameRate.max,
      ),
    );
  }
}

class BlinkLoadingOverlay extends StatelessWidget {
  final String? message;

  const BlinkLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BlinkAnimation(type: BlinkAnimationType.loading, size: 100),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BlinkResultOverlay extends StatelessWidget {
  final bool isSuccess;
  final String? message;

  const BlinkResultOverlay({
    super.key,
    required this.isSuccess,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlinkAnimation(
            type: isSuccess ? BlinkAnimationType.success : BlinkAnimationType.error,
            size: 100,
            repeat: false,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: isSuccess
                    ? const Color(0xFF00D9FF)
                    : const Color(0xFFFF4D4D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
