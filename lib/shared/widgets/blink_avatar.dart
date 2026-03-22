import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Avatar sizes following the design system.
enum BlinkAvatarSize {
  xs,  // 32px
  sm,  // 40px
  md,  // 56px
  lg,  // 80px
  xl,  // 120px
}

/// Avatar component with image, initials, or icon fallback.
///
/// Supports online status indicator and selection state.
class BlinkAvatar extends StatelessWidget {
  const BlinkAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon,
    this.size = BlinkAvatarSize.md,
    this.isOnline = false,
    this.isSelected = false,
    this.backgroundColor,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final IconData? icon;
  final BlinkAvatarSize size;
  final bool isOnline;
  final bool isSelected;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  double get _dimension => switch (size) {
    BlinkAvatarSize.xs => BlinkSpacing.avatarXs,
    BlinkAvatarSize.sm => BlinkSpacing.avatarSm,
    BlinkAvatarSize.md => BlinkSpacing.avatarMd,
    BlinkAvatarSize.lg => BlinkSpacing.avatarLg,
    BlinkAvatarSize.xl => BlinkSpacing.avatarXl,
  };

  double get _fontSize => switch (size) {
    BlinkAvatarSize.xs => 12,
    BlinkAvatarSize.sm => 14,
    BlinkAvatarSize.md => 20,
    BlinkAvatarSize.lg => 28,
    BlinkAvatarSize.xl => 40,
  };

  double get _iconSize => switch (size) {
    BlinkAvatarSize.xs => 16,
    BlinkAvatarSize.sm => 20,
    BlinkAvatarSize.md => 28,
    BlinkAvatarSize.lg => 40,
    BlinkAvatarSize.xl => 56,
  };

  double get _statusSize => switch (size) {
    BlinkAvatarSize.xs => 8,
    BlinkAvatarSize.sm => 10,
    BlinkAvatarSize.md => 12,
    BlinkAvatarSize.lg => 16,
    BlinkAvatarSize.xl => 20,
  };

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _dimension,
      height: _dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? BlinkColors.darkSurface,
        border: Border.all(
          color: isSelected
              ? BlinkColors.primary
              : isOnline
                  ? BlinkColors.success
                  : BlinkColors.darkElevated,
          width: isSelected ? 2.5 : 2,
        ),
        boxShadow: isSelected ? BlinkShadows.glowPrimary : null,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: icon != null
                  ? Icon(
                      icon,
                      size: _iconSize,
                      color: BlinkColors.primaryLight,
                    )
                  : Text(
                      _initials,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w600,
                        color: BlinkColors.darkTextPrimary,
                      ),
                    ),
            )
          : null,
    );

    // Online status indicator
    if (isOnline) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: _statusSize,
              height: _statusSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BlinkColors.success,
                border: Border.all(
                  color: BlinkColors.darkBackground,
                  width: 2,
                ),
                boxShadow: BlinkShadows.glowSuccess,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

/// A stack of multiple avatars (for groups).
class BlinkAvatarStack extends StatelessWidget {
  const BlinkAvatarStack({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.size = BlinkAvatarSize.sm,
  });

  final List<AvatarData> avatars;
  final int maxVisible;
  final BlinkAvatarSize size;

  double get _dimension => switch (size) {
    BlinkAvatarSize.xs => BlinkSpacing.avatarXs,
    BlinkAvatarSize.sm => BlinkSpacing.avatarSm,
    BlinkAvatarSize.md => BlinkSpacing.avatarMd,
    BlinkAvatarSize.lg => BlinkSpacing.avatarLg,
    BlinkAvatarSize.xl => BlinkSpacing.avatarXl,
  };

  double get _overlap => _dimension * 0.3;

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    return SizedBox(
      height: _dimension,
      child: Stack(
        children: [
          ...visible.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Positioned(
              left: index * (_dimension - _overlap),
              child: BlinkAvatar(
                imageUrl: data.imageUrl,
                name: data.name,
                size: size,
                isOnline: data.isOnline,
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: visible.length * (_dimension - _overlap),
              child: Container(
                width: _dimension,
                height: _dimension,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BlinkColors.darkElevated,
                  border: Border.all(
                    color: BlinkColors.darkBackground,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      fontSize: _dimension * 0.35,
                      fontWeight: FontWeight.w600,
                      color: BlinkColors.darkTextSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Data class for avatar stack
class AvatarData {
  final String? imageUrl;
  final String? name;
  final bool isOnline;

  const AvatarData({
    this.imageUrl,
    this.name,
    this.isOnline = false,
  });
}
