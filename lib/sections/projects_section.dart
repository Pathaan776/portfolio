import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1100 ? 3 : (w >= 720 ? 2 : 1);
    final featured = PortfolioData.projects.where((p) => p.featured).toList();
    final rest = PortfolioData.projects.where((p) => !p.featured).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          index: '03',
          title: 'Featured work',
          subtitle: 'A few apps I have built. The first two are live on Google Play right now.',
        ),
        const SizedBox(height: 48),
        // Side by side on wide screens, stacked on smaller ones.
        if (w >= 1000 && featured.length > 1)
          _FeaturedRow(projects: featured)
        else
          for (final p in featured) ...[
            Reveal(child: _FeaturedCard(project: p)),
            const SizedBox(height: 28),
          ],
        if (w >= 1000 && featured.length > 1) const SizedBox(height: 28),
        const SizedBox(height: 36),
        const _SubHeading(
          title: 'Side projects with AI',
          subtitle: 'Things I build after work to try new ideas.',
        ),
        const SizedBox(height: 24),
        if (w >= 1000)
          _FeaturedRow(projects: PortfolioData.aiProjects)
        else
          for (final p in PortfolioData.aiProjects) ...[
            Reveal(child: _FeaturedCard(project: p)),
            const SizedBox(height: 28),
          ],
        const SizedBox(height: 64),
        const _SubHeading(
          title: 'Client work',
          subtitle: 'Apps I built at Quick Web Codes between 2020 and 2024.',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 24.0;
            final cardW = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < rest.length; i++)
                  SizedBox(
                    width: cardW,
                    child: Reveal(
                      delay: Duration(milliseconds: 100 * (i % cols)),
                      child: _TiltCard(
                        accent: rest[i].accent,
                        child: _ProjectBody(project: rest[i]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Featured cards side by side with equal height.
/// Each card is measured after layout and the shortest ones get a min-height
/// equal to the tallest, so nothing can overflow (no IntrinsicHeight needed).
class _FeaturedRow extends StatefulWidget {
  final List<Project> projects;
  const _FeaturedRow({required this.projects});

  @override
  State<_FeaturedRow> createState() => _FeaturedRowState();
}

class _FeaturedRowState extends State<_FeaturedRow> {
  late final List<GlobalKey> _keys =
      List.generate(widget.projects.length, (_) => GlobalKey());
  double? _minHeight;
  double? _forWidth;
  bool _scheduled = false;

  void _scheduleMeasure() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      var tallest = 0.0;
      for (final k in _keys) {
        final box = k.currentContext?.findRenderObject();
        if (box is RenderBox && box.hasSize) {
          tallest = math.max(tallest, box.size.height);
        }
      }
      if (tallest > 0 && (_minHeight == null || (tallest - _minHeight!).abs() > 0.5)) {
        setState(() => _minHeight = tallest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (_forWidth != c.maxWidth) {
          // Width changed: let cards take their natural height, then re-measure.
          _forWidth = c.maxWidth;
          _minHeight = null;
        }
        _scheduleMeasure();
        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (_) {
            _scheduleMeasure();
            return true;
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.projects.length; i++) ...[
                if (i > 0) const SizedBox(width: 24),
                Expanded(
                  child: Reveal(
                    delay: Duration(milliseconds: 150 * i),
                    child: SizeChangedLayoutNotifier(
                      child: ConstrainedBox(
                        key: _keys[i],
                        constraints:
                            BoxConstraints(minHeight: _minHeight ?? 0),
                        child: _FeaturedCard(
                          project: widget.projects[i],
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Card that tilts toward the cursor and glows in its accent colour.
class _TiltCard extends StatefulWidget {
  final Widget child;
  final Color accent;
  final double minHeight;
  const _TiltCard({
    required this.child,
    required this.accent,
    this.minHeight = 290,
  });

  @override
  State<_TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<_TiltCard> {
  Offset _tilt = Offset.zero; // -1..1
  bool _hover = false;

  void _onHover(PointerHoverEvent e, Size size) {
    setState(() {
      _tilt = Offset(
        (e.localPosition.dx / size.width) * 2 - 1,
        (e.localPosition.dy / size.height) * 2 - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() {
            _hover = false;
            _tilt = Offset.zero;
          }),
          onHover: (e) {
            final box = context.findRenderObject();
            if (box is RenderBox && box.hasSize) _onHover(e, box.size);
          },
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: _tilt),
            duration: const Duration(milliseconds: 180),
            builder: (context, t, child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(-t.dy * 0.12)
                ..rotateY(t.dx * 0.12),
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              constraints: BoxConstraints(minHeight: widget.minHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors.card.withOpacity(0.75),
                border: Border.all(
                  color: _hover
                      ? widget.accent.withOpacity(0.8)
                      : AppColors.border,
                ),
                gradient: _hover
                    ? RadialGradient(
                        center: Alignment(_tilt.dx, _tilt.dy),
                        radius: 1.2,
                        colors: [
                          widget.accent.withOpacity(0.18),
                          AppColors.card.withOpacity(0.75),
                        ],
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.accent.withOpacity(_hover ? 0.3 : 0),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _ProjectBody extends StatelessWidget {
  final Project project;
  const _ProjectBody({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: p.accent.withOpacity(0.14),
                  border: Border.all(color: p.accent.withOpacity(0.4)),
                ),
                child: Icon(p.icon, color: p.accent, size: 26),
              ),
              const Spacer(),
              const Icon(Icons.north_east_rounded,
                  color: AppColors.muted, size: 20),
            ],
          ),
          const SizedBox(height: 22),
          Text(p.title, style: AppTheme.display(22, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(p.subtitle, style: AppTheme.mono(12, color: p.accent)),
          const SizedBox(height: 14),
          Text(
            p.description,
            style: const TextStyle(
                color: AppColors.muted, fontSize: 14.5, height: 1.6),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in p.tags) TagChip(t, color: p.accent)],
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Project project;

  /// Half-width layout used when two featured cards sit in one row.
  final bool compact;
  const _FeaturedCard({required this.project, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final p = project;
    final wide = !compact && MediaQuery.sizeOf(context).width >= 900;
    final live = p.links.where((l) => !l.comingSoon).map((l) => l.label).toList();
    final onPlay = live.contains('Google Play');
    final onApple = live.contains('App Store');
    final liveTag = TagChip(
      p.badge ??
      (onPlay && onApple
          ? 'LIVE ON PLAY STORE & APP STORE'
          : (onApple ? 'LIVE ON APP STORE' : 'LIVE ON PLAY STORE')),
      color: p.accent,
    );

    final details = <Widget>[
      Text(
        p.description,
        style: const TextStyle(color: AppColors.muted, fontSize: 16, height: 1.7),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final t in p.tags) TagChip(t, color: p.accent)],
      ),
    ];

    final buttons = Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (var i = 0; i < p.links.length; i++)
          if (p.links[i].comingSoon)
            _ComingSoonButton(link: p.links[i])
          else
            GlowButton(
              label: p.links[i].label,
              icon: p.links[i].icon,
              filled: i == 0,
              onTap: () => openUrl(p.links[i].url),
            ),
      ],
    );

    if (compact) {
      return _TiltCard(
        accent: p.accent,
        minHeight: 0,
        child: Padding(
          padding: const EdgeInsets.all(34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        liveTag,
                        const SizedBox(height: 18),
                        GradientText(p.title, style: AppTheme.display(38)),
                        const SizedBox(height: 6),
                        Text(p.subtitle,
                            style: AppTheme.mono(13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _FeaturedVisual(
                    accent: p.accent,
                    icon: p.icon,
                    size: 120,
                    labels: const [],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ...details,
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: buttons,
              ),
            ],
          ),
        ),
      );
    }

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        liveTag,
        const SizedBox(height: 20),
        GradientText(p.title, style: AppTheme.display(wide ? 44 : 34)),
        const SizedBox(height: 6),
        Text(p.subtitle, style: AppTheme.mono(14, color: AppColors.muted)),
        const SizedBox(height: 18),
        ...details,
        const SizedBox(height: 28),
        buttons,
      ],
    );

    final visual = Padding(
      padding: const EdgeInsets.all(28),
      child: _FeaturedVisual(accent: p.accent, icon: p.icon, labels: p.orbit),
    );

    return _TiltCard(
      accent: p.accent,
      minHeight: 0,
      child: Padding(
        padding: EdgeInsets.all(wide ? 44 : 26),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 6, child: info),
                  const SizedBox(width: 40),
                  Expanded(flex: 4, child: visual),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [info, const SizedBox(height: 32), visual],
              ),
      ),
    );
  }
}

/// Orbiting rings around the project icon.
/// Pass [size] for a fixed size (needed inside IntrinsicHeight); otherwise it
/// fills the available width as a square.
class _FeaturedVisual extends StatefulWidget {
  final Color accent;
  final IconData icon;
  final double? size;
  final List<String> labels;
  const _FeaturedVisual({
    required this.accent,
    required this.icon,
    this.size,
    this.labels = const [],
  });

  @override
  State<_FeaturedVisual> createState() => _FeaturedVisualState();
}

class _FeaturedVisualState extends State<_FeaturedVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _orbit(double s) {
    final labels = widget.labels;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final a = _c.value * 2 * math.pi;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final f in [1.0, 0.72, 0.46])
              Container(
                width: s * f,
                height: s * f,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.accent.withOpacity(0.18 + (1 - f) * 0.2)),
                ),
              ),
            Container(
              width: s * 0.3,
              height: s * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradient,
                boxShadow: [
                  BoxShadow(color: widget.accent.withOpacity(0.6), blurRadius: 40),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: s * 0.14),
            ),
            if (labels.isEmpty)
              // Small glowing dots riding the rings.
              for (var i = 0; i < 3; i++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    (i.isEven ? a : -a) + i * 2.1,
                    s * [0.5, 0.36, 0.23][i],
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent,
                      boxShadow: [
                        BoxShadow(color: widget.accent, blurRadius: 10),
                      ],
                    ),
                  ),
                )
            else
              for (var i = 0; i < labels.length; i++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    a + i * 2 * math.pi / labels.length,
                    s * (i.isEven ? 0.5 : 0.36),
                  ),
                  child: TagChip(
                    labels[i],
                    color: i.isEven ? AppColors.secondary : AppColors.accent,
                  ),
                ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: _orbit(widget.size!),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, c) => _orbit(c.maxWidth)),
    );
  }
}

/// Store button for a build that is still in review: muted, not clickable,
/// with a softly pulsing "In review" badge.
class _ComingSoonButton extends StatefulWidget {
  final ProjectLink link;
  const _ComingSoonButton({required this.link});

  @override
  State<_ComingSoonButton> createState() => _ComingSoonButtonState();
}

class _ComingSoonButtonState extends State<_ComingSoonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'iOS app is in App Store review. Coming soon.',
      child: MouseRegion(
        cursor: SystemMouseCursors.forbidden,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            color: AppColors.card.withOpacity(0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.link.icon, size: 18, color: AppColors.muted),
              const SizedBox(width: 10),
              Text(
                widget.link.label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedBuilder(
                animation: _c,
                builder: (context, child) => Opacity(
                  opacity: 0.55 + 0.45 * _c.value,
                  child: child,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB547).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color(0xFFFFB547).withOpacity(0.5)),
                  ),
                  child: Text(
                    'IN REVIEW',
                    style: AppTheme.mono(10, color: const Color(0xFFFFB547)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small heading used to split the Work section into groups.
class _SubHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SubHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.display(26, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.muted, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
