import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Navigation item data for bottom nav and sidebar.
class BlinkNavItem {
  final String label;
  final String iconPath;     // SVG asset path
  final String? activeIconPath; // Optional filled variant
  final String route;

  const BlinkNavItem({
    required this.label,
    required this.iconPath,
    this.activeIconPath,
    required this.route,
  });
}

/// Mobile bottom navigation bar following Blink's design system.
///
/// Features:
/// - 80px height (including safe area)
/// - #0D0D12 background with blur
/// - Active item: #6C63FF icon
/// - Inactive: #666680 icon
/// - Label only shown for active item
class BlinkBottomNav extends StatelessWidget {
  const BlinkBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BlinkNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      height: BlinkSpacing.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: BlinkColors.darkBackground.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: BlinkColors.darkHover.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == currentIndex;

            return _NavItem(
              item: item,
              isActive: isActive,
              onTap: () => onTap(index),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final BlinkNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = widget.isActive && widget.item.activeIconPath != null
        ? widget.item.activeIconPath!
        : widget.item.iconPath;
    final color = widget.isActive
        ? BlinkColors.primary
        : BlinkColors.darkTextTertiary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              if (widget.isActive) ...[
                const SizedBox(height: 4),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop sidebar rail navigation.
///
/// Features:
/// - 72px collapsed, 240px expanded
/// - Active item has #6C63FF pill background
/// - Collapse/expand button at bottom
class BlinkSidebar extends StatefulWidget {
  const BlinkSidebar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.header,
    this.footer,
    this.isExpanded = false,
    this.onExpandToggle,
  });

  final List<BlinkNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget? header;
  final Widget? footer;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;

  @override
  State<BlinkSidebar> createState() => _BlinkSidebarState();
}

class _BlinkSidebarState extends State<BlinkSidebar> {
  @override
  Widget build(BuildContext context) {
    final width = widget.isExpanded
        ? BlinkSpacing.sidebarExpandedWidth
        : BlinkSpacing.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      color: BlinkColors.darkBackground,
      child: Column(
        children: [
          // Header (logo, user info)
          if (widget.header != null)
            Padding(
              padding: const EdgeInsets.all(BlinkSpacing.md),
              child: widget.header,
            ),

          const SizedBox(height: BlinkSpacing.md),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: BlinkSpacing.sm),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isActive = index == widget.currentIndex;

                return _SidebarItem(
                  item: item,
                  isActive: isActive,
                  isExpanded: widget.isExpanded,
                  onTap: () => widget.onTap(index),
                );
              },
            ),
          ),

          // Footer (collapse button, settings)
          if (widget.footer != null)
            widget.footer!
          else if (widget.onExpandToggle != null)
            _CollapseButton(
              isExpanded: widget.isExpanded,
              onTap: widget.onExpandToggle!,
            ),

          const SizedBox(height: BlinkSpacing.md),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
  });

  final BlinkNavItem item;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final iconPath = widget.isActive && widget.item.activeIconPath != null
        ? widget.item.activeIconPath!
        : widget.item.iconPath;
    final color = widget.isActive
        ? BlinkColors.white
        : _isHovered
            ? BlinkColors.darkTextPrimary
            : BlinkColors.darkTextSecondary;
    final backgroundColor = widget.isActive
        ? BlinkColors.primary
        : _isHovered
            ? BlinkColors.darkHover
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: BlinkSpacing.xs),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? BlinkSpacing.md : BlinkSpacing.sm,
              vertical: BlinkSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(BlinkRadius.md),
            ),
            child: Row(
              mainAxisAlignment: widget.isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: BlinkSpacing.md),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            widget.isActive ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  const _CollapseButton({
    required this.isExpanded,
    required this.onTap,
  });

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BlinkSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BlinkSpacing.sm),
          decoration: BoxDecoration(
            color: BlinkColors.darkSurface,
            borderRadius: BorderRadius.circular(BlinkRadius.md),
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                isExpanded
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 24,
                color: BlinkColors.darkTextSecondary,
              ),
              if (isExpanded) ...[
                const SizedBox(width: BlinkSpacing.sm),
                const Text(
                  'Collapse',
                  style: TextStyle(
                    fontSize: 14,
                    color: BlinkColors.darkTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Adaptive navigation shell that switches between bottom nav (mobile)
/// and sidebar (desktop) based on screen width.
class BlinkAdaptiveShell extends StatelessWidget {
  const BlinkAdaptiveShell({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onNavigate,
    required this.child,
    this.sidebarHeader,
    this.breakpoint = 800,
  });

  final List<BlinkNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final Widget child;
  final Widget? sidebarHeader;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= breakpoint;

        if (isDesktop) {
          return _DesktopLayout(
            items: items,
            currentIndex: currentIndex,
            onNavigate: onNavigate,
            header: sidebarHeader,
            child: child,
          );
        }

        return _MobileLayout(
          items: items,
          currentIndex: currentIndex,
          onNavigate: onNavigate,
          child: child,
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.items,
    required this.currentIndex,
    required this.onNavigate,
    required this.child,
  });

  final List<BlinkNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: child,
      bottomNavigationBar: BlinkBottomNav(
        items: items,
        currentIndex: currentIndex,
        onTap: onNavigate,
      ),
    );
  }
}

class _DesktopLayout extends StatefulWidget {
  const _DesktopLayout({
    required this.items,
    required this.currentIndex,
    required this.onNavigate,
    required this.child,
    this.header,
  });

  final List<BlinkNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final Widget child;
  final Widget? header;

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlinkColors.darkBackground,
      body: Row(
        children: [
          BlinkSidebar(
            items: widget.items,
            currentIndex: widget.currentIndex,
            onTap: widget.onNavigate,
            header: widget.header,
            isExpanded: _isExpanded,
            onExpandToggle: () => setState(() => _isExpanded = !_isExpanded),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
