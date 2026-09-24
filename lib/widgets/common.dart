import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  final isMail = uri.scheme == 'mailto' || uri.scheme == 'tel';
  await launchUrl(uri, webOnlyWindowName: isMail ? '_self' : '_blank');
}

/// Fades + slides its child in the first time it scrolls into view.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset from;
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.from = const Offset(0, 40),
  });

  /// The reveal animation of the nearest [Reveal] ancestor (0 → 1), if any.
  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RevealScope>()?.animation;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealScope extends InheritedWidget {
  final Animation<double> animation;
  const _RevealScope({required this.animation, required super.child});

  @override
  bool updateShouldNotify(_RevealScope old) => old.animation != animation;
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  final List<ScrollPosition> _positions = [];
  bool _started = false;

  void _unlisten() {
    for (final p in _positions) {
      p.removeListener(_check);
    }
    _positions.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unlisten();
    // Listen to every enclosing scrollable (nested grids/lists included),
    // so the page scroll always triggers the check.
    BuildContext ctx = context;
    while (true) {
      final s = Scrollable.maybeOf(ctx);
      if (s == null) break;
      _positions.add(s.position);
      s.position.addListener(_check);
      ctx = s.context;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started || !mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final screenH = MediaQuery.sizeOf(context).height;
    if (top < screenH * 0.92) {
      _started = true;
      _unlisten();
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _unlisten();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: _RevealScope(animation: _c, child: widget.child),
      builder: (context, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: widget.from * (1 - _a.value),
          child: child,
        ),
      ),
    );
  }
}

/// Text filled with the brand gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? align;
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppColors.gradient,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => gradient.createShader(Offset.zero & r.size),
      child: Text(text, style: style, textAlign: align),
    );
  }
}

/// "01. About" style section heading.
class SectionHeader extends StatelessWidget {
  final String index;
  final String title;
  final String? subtitle;
  const SectionHeader({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('// $index', style: AppTheme.mono(14)),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: Text(title, style: AppTheme.display(mobile ? 34 : 48))),
              const SizedBox(width: 20),
              if (!mobile)
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withOpacity(0.6),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(subtitle!,
                style: const TextStyle(color: AppColors.muted, fontSize: 16)),
          ],
        ],
      ),
    );
  }
}

/// Button with gradient fill (primary) or outline (secondary), hover lift + glow.
class GlowButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;
  const GlowButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.filled ? AppColors.gradient : null,
            color: widget.filled
                ? null
                : (_hover
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            border: widget.filled
                ? null
                : Border.all(
                    color: _hover ? AppColors.primary : AppColors.border,
                  ),
            boxShadow: [
              if (widget.filled)
                BoxShadow(
                  color: AppColors.primary.withOpacity(_hover ? 0.55 : 0.25),
                  blurRadius: _hover ? 30 : 16,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill used for tech tags.
class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const TagChip(this.label, {super.key, this.color = AppColors.secondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(label, style: AppTheme.mono(12, color: color)),
    );
  }
}
