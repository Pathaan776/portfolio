import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import 'animated_background.dart';
import 'common.dart';

class NavItem {
  final String label;
  final VoidCallback onTap;
  const NavItem(this.label, this.onTap);
}

/// Floating glass nav bar with a scroll-progress line and active section.
class NavBar extends StatelessWidget {
  final List<NavItem> items;
  final int active;
  final double progress; // 0..1 page scroll
  final bool scrolled;
  final VoidCallback onLogo;

  const NavBar({
    super.key,
    required this.items,
    required this.active,
    required this.progress,
    required this.scrolled,
    required this.onLogo,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    final compact = MediaQuery.sizeOf(context).width < 1000;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 12 : (scrolled ? 40 : 24),
        vertical: scrolled ? 12 : 20,
      ),
      child: Glass(
        blur: 18,
        radius: BorderRadius.circular(18),
        padding: EdgeInsets.zero,
        borderColor: scrolled ? AppColors.border : Colors.transparent,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 16 : 24, vertical: 12),
              child: Row(
                children: [
                  _Logo(onTap: onLogo),
                  const Spacer(),
                  if (compact)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      color: AppColors.text,
                      onPressed: () => _openMenu(context),
                    )
                  else ...[
                    for (var i = 0; i < items.length; i++)
                      _NavLink(
                        index: i,
                        label: items[i].label,
                        active: i == active,
                        onTap: items[i].onTap,
                      ),
                    const SizedBox(width: 12),
                    GlowButton(
                      label: 'Hire me',
                      onTap: () => openUrl('mailto:${PortfolioData.email}'),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(gradient: AppColors.gradient),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < items.length; i++)
                ListTile(
                  leading: Text('0${i + 1}.', style: AppTheme.mono(14)),
                  title: Text(items[i].label,
                      style: AppTheme.display(20, weight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    items[i].onTap();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatefulWidget {
  final VoidCallback onTap;
  const _Logo({required this.onTap});

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: _hover ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text('RK',
                    style: AppTheme.display(15).copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Text('rahish', style: AppTheme.display(18, weight: FontWeight.w700)),
            Text('.dev', style: AppTheme.display(18, weight: FontWeight.w700)
                .copyWith(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final int index;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({
    required this.index,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final on = _hover || widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('0${widget.index + 1}.',
                      style: AppTheme.mono(12)),
                  const SizedBox(width: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: on ? AppColors.text : AppColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 2,
                width: on ? 28 : 0,
                decoration: const BoxDecoration(gradient: AppColors.gradient),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
