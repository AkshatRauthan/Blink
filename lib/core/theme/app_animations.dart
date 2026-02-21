import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Blink motion tokens — durations, curves, and reusable animate effects.
///
/// Designed to feel iOS-native: snappy, spring-based, with subtle micro-delays.
///
/// Usage with flutter_animate:
/// ```dart
/// widget.animate(effects: BlinkAnimations.fadeSlideUp);
/// widget.animate().fadeIn(duration: BlinkDurations.standard);
/// ```
abstract class BlinkDurations {
  /// Micro-interactions: toggle, checkbox, icon change.
  static const Duration instant = Duration(milliseconds: 100);

  /// Quick feedback: button press, ripple, chip tap.
  static const Duration quick = Duration(milliseconds: 200);

  /// Standard transitions: page cross-fade, card expand.
  static const Duration standard = Duration(milliseconds: 350);

  /// Emphasis animations: modal appear, bottom sheet slide.
  static const Duration emphasis = Duration(milliseconds: 500);

  /// Slow / cinematic: onboarding hero, splash fade-out.
  static const Duration slow = Duration(milliseconds: 700);

  /// Stagger delay between items in lists / grids.
  static const Duration stagger = Duration(milliseconds: 50);
}

/// Custom curves that feel more iOS / SwiftUI-like than Material defaults.
abstract class BlinkCurves {
  /// Primary easing — slightly slower at the end for a "settling" feel.
  static const Curve standard = Curves.easeOutCubic;

  /// Enter screen / appear.
  static const Curve enter = Curves.easeOutBack;

  /// Leave screen / disappear.
  static const Curve exit = Curves.easeInCubic;

  /// Spring-like bounce for playful micro-interactions.
  static const Curve spring = Curves.elasticOut;

  /// Smooth deceleration for drag-release / fling.
  static const Curve decelerate = Curves.decelerate;

  /// Linear for progress bars and continuous animations.
  static const Curve linear = Curves.linear;

  /// Gentle overshoot then settle (good for icons, FABs).
  static const Curve overshoot = Cubic(0.34, 1.56, 0.64, 1.0);
}

/// Pre-built [Effect] lists for common entrance patterns.
///
/// Usage: `widget.animate(effects: BlinkAnimations.fadeSlideUp)`
abstract class BlinkEffects {
  // ── Entrances ─────────────────────────────────────────────────────

  /// Fade + slide from 24 px below (cards, list items).
  static List<Effect> get fadeSlideUp => [
        FadeEffect(
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        ),
        SlideEffect(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        ),
      ];

  /// Fade + slide from 12 px right (detail panel, side content).
  static List<Effect> get fadeSlideRight => [
        FadeEffect(
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        ),
        SlideEffect(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        ),
      ];

  /// Scale from 90 % + fade (modals, dialogs).
  static List<Effect> get scaleIn => [
        FadeEffect(
          duration: BlinkDurations.standard,
          curve: BlinkCurves.standard,
        ),
        ScaleEffect(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: BlinkDurations.standard,
          curve: BlinkCurves.enter,
        ),
      ];

  /// Subtle blur-in (hero elements, splash).
  static List<Effect> get blurIn => [
        FadeEffect(
          duration: BlinkDurations.emphasis,
          curve: BlinkCurves.standard,
        ),
        BlurEffect(
          begin: const Offset(8, 8),
          end: Offset.zero,
          duration: BlinkDurations.emphasis,
          curve: BlinkCurves.standard,
        ),
      ];

  // ── Shimmer / loading ─────────────────────────────────────────────

  /// Continuous shimmer for skeleton placeholders.
  static List<Effect> get shimmerLoop => [
        ShimmerEffect(
          duration: const Duration(milliseconds: 1500),
          color: const Color(0x20FFFFFF),
        ),
      ];
}
