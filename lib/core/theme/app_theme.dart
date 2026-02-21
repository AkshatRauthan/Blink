import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Blink's master theme factory.
///
/// Produces fully-configured [ThemeData] for light and dark modes by
/// combining all design tokens (colors, typography, spacing, shapes).
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: BlinkTheme.light(),
///   darkTheme: BlinkTheme.dark(),
/// );
/// ```
abstract class BlinkTheme {
  // ──────────────────────────────────────────────────────────────────
  // Light theme
  // ──────────────────────────────────────────────────────────────────
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Brand
      primary: BlinkColors.primary,
      onPrimary: BlinkColors.white,
      primaryContainer: BlinkColors.primaryLight,
      onPrimaryContainer: BlinkColors.primaryDark,
      // Secondary — accent cyan
      secondary: BlinkColors.accent,
      onSecondary: BlinkColors.white,
      secondaryContainer: BlinkColors.accent.withValues(alpha: 0.12),
      onSecondaryContainer: BlinkColors.accent,
      // Tertiary — coral
      tertiary: BlinkColors.coral,
      onTertiary: BlinkColors.white,
      tertiaryContainer: BlinkColors.coral.withValues(alpha: 0.12),
      onTertiaryContainer: BlinkColors.coral,
      // Surfaces
      surface: BlinkColors.lightSurface,
      onSurface: BlinkColors.lightTextPrimary,
      surfaceContainerHighest: BlinkColors.lightSurfaceVariant,
      onSurfaceVariant: BlinkColors.lightTextSecondary,
      // Errors
      error: BlinkColors.error,
      onError: BlinkColors.white,
      errorContainer: BlinkColors.error.withValues(alpha: 0.12),
      onErrorContainer: BlinkColors.error,
      // Outline / misc
      outline: BlinkColors.lightCardBorder,
      outlineVariant: BlinkColors.lightSurfaceVariant,
      shadow: BlinkColors.black.withValues(alpha: 0.08),
      scrim: BlinkColors.black.withValues(alpha: 0.32),
    );

    final textTheme = BlinkTypography.textTheme(Brightness.light);

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: Brightness.light,
      scaffoldBackground: BlinkColors.lightBackground,
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Dark theme
  // ──────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Brand
      primary: BlinkColors.primaryLight, // lighter in dark mode
      onPrimary: BlinkColors.primaryDark,
      primaryContainer: BlinkColors.primary,
      onPrimaryContainer: BlinkColors.primaryLight,
      // Secondary
      secondary: BlinkColors.accent,
      onSecondary: BlinkColors.black,
      secondaryContainer: BlinkColors.accent.withValues(alpha: 0.20),
      onSecondaryContainer: BlinkColors.accent,
      // Tertiary
      tertiary: BlinkColors.coral,
      onTertiary: BlinkColors.black,
      tertiaryContainer: BlinkColors.coral.withValues(alpha: 0.20),
      onTertiaryContainer: BlinkColors.coral,
      // Surfaces
      surface: BlinkColors.darkSurface,
      onSurface: BlinkColors.darkTextPrimary,
      surfaceContainerHighest: BlinkColors.darkSurfaceVariant,
      onSurfaceVariant: BlinkColors.darkTextSecondary,
      // Errors
      error: BlinkColors.error,
      onError: BlinkColors.white,
      errorContainer: BlinkColors.error.withValues(alpha: 0.20),
      onErrorContainer: BlinkColors.error,
      // Outline / misc
      outline: BlinkColors.darkCardBorder,
      outlineVariant: BlinkColors.darkSurfaceVariant,
      shadow: BlinkColors.black.withValues(alpha: 0.40),
      scrim: BlinkColors.black.withValues(alpha: 0.60),
    );

    final textTheme = BlinkTypography.textTheme(Brightness.dark);

    return _buildTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: Brightness.dark,
      scaffoldBackground: BlinkColors.darkBackground,
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // Shared builder
  // ──────────────────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Brightness brightness,
    required Color scaffoldBackground,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBackground,

      // ── Visual density ──────────────────────────────────────────
      visualDensity: VisualDensity.standard,

      // ── Splash / ink (iOS-like: no ink splash, subtle highlight) ─
      splashFactory: NoSplash.splashFactory,
      highlightColor: colorScheme.primary.withValues(alpha: 0.06),

      // ── Status bar / system UI ──────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              ),
      ),

      // ── Cards ───────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.lg),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.md,
          vertical: BlinkSpacing.sm,
        ),
      ),

      // ── Elevated buttons (primary actions) ──────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, BlinkSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BlinkRadius.md),
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: BlinkSpacing.lg,
            vertical: BlinkSpacing.md,
          ),
        ),
      ),

      // ── Outlined buttons (secondary actions) ────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, BlinkSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BlinkRadius.md),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: BlinkSpacing.lg,
            vertical: BlinkSpacing.md,
          ),
        ),
      ),

      // ── Text buttons (tertiary actions) ─────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BlinkRadius.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Floating action button ──────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.lg),
        ),
      ),

      // ── Input fields ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? BlinkColors.lightSurfaceVariant
            : BlinkColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.md,
          vertical: BlinkSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        labelStyle: textTheme.bodyMedium,
      ),

      // ── Bottom navigation / navigation bar ─────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(
              color: colorScheme.onSurfaceVariant, size: 24);
        }),
      ),

      // ── Bottom sheet ────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(BlinkRadius.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurface.withValues(alpha: 0.2),
      ),

      // ── Dialog ──────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.xl),
        ),
        titleTextStyle: textTheme.headlineMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.full),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.sm,
          vertical: BlinkSpacing.xs,
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.3),
        thickness: 0.5,
        space: 0,
      ),

      // ── Snackbar ────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
        ),
        backgroundColor:
            isLight ? BlinkColors.darkSurface : BlinkColors.lightSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isLight
              ? BlinkColors.darkTextPrimary
              : BlinkColors.lightTextPrimary,
        ),
      ),

      // ── Tooltip ─────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? BlinkColors.darkSurface : BlinkColors.lightSurface,
          borderRadius: BorderRadius.circular(BlinkRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: isLight
              ? BlinkColors.darkTextPrimary
              : BlinkColors.lightTextPrimary,
        ),
      ),

      // ── Icon ────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: BlinkSpacing.iconMd,
      ),

      // ── List tile ───────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BlinkSpacing.md,
          vertical: BlinkSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BlinkRadius.md),
        ),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),

      // ── Progress indicator ──────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.12),
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.12),
        linearMinHeight: 4,
      ),

      // ── Switch / toggle ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ── Page transitions (iOS-like slide) ───────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
