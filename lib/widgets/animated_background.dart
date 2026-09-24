import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fixed full-screen backdrop: slowly drifting glow orbs, a constellation of
/// particles, and a soft spotlight that follows the mouse.
class AnimatedBackground extends StatefulWidget {
  /// Mouse position in global coordinates, supplied by the page.
  final ValueNotifier<Offset?> mouse;
  const AnimatedBackground({super.key, required this.mouse});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  final _clock = Stopwatch()..start();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final r = math.Random(7);
    _particles = List.generate(
      70,
      (_) => _Particle(
        x: r.nextDouble(),
        y: r.nextDouble(),
        vx: (r.nextDouble() - 0.5) * 0.6,
        vy: (r.nextDouble() - 0.5) * 0.6,
        size: r.nextDouble() * 1.8 + 0.6,
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BgPainter(_c, _clock, _particles, widget.mouse),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  final double x, y, vx, vy, size;
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
  });
}

class _BgPainter extends CustomPainter {
  final Animation<double> anim;
  final Stopwatch clock;
  final List<_Particle> particles;
  final ValueNotifier<Offset?> mouse;

  _BgPainter(this.anim, this.clock, this.particles, this.mouse)
      : super(repaint: Listenable.merge([anim, mouse]));

  double _wrap(double v) => v - v.floorToDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final secs = clock.elapsedMilliseconds / 1000.0;
    final t = secs / 40 * 2 * math.pi;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.bg);

    // Glow orbs
    void orb(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withOpacity(0.30), color.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final w = size.width, h = size.height;
    final base = math.max(w, h);
    orb(Offset(w * (0.2 + 0.08 * math.sin(t)), h * (0.25 + 0.1 * math.cos(t))),
        base * 0.45, AppColors.primary);
    orb(Offset(w * (0.85 + 0.06 * math.cos(t * 2)), h * (0.7 + 0.08 * math.sin(t))),
        base * 0.40, AppColors.secondary);
    orb(Offset(w * (0.55 + 0.1 * math.sin(t * 3)), h * (0.1 + 0.05 * math.cos(t * 2))),
        base * 0.30, AppColors.accent);

    // Particles
    final pts = <Offset>[];
    for (final p in particles) {
      final px = _wrap(p.x + p.vx * secs / 40) * w;
      final py = _wrap(p.y + p.vy * secs / 40) * h;
      pts.add(Offset(px, py));
    }

    final linkDist = math.min(140.0, w / 6);
    final line = Paint()..strokeWidth = 0.6;
    for (var i = 0; i < pts.length; i++) {
      for (var j = i + 1; j < pts.length; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < linkDist) {
          line.color = AppColors.primary.withOpacity(0.18 * (1 - d / linkDist));
          canvas.drawLine(pts[i], pts[j], line);
        }
      }
    }

    final dot = Paint()..color = Colors.white.withOpacity(0.55);
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], particles[i].size, dot);
    }

    // Mouse spotlight + links to nearby particles
    final m = mouse.value;
    if (m != null) {
      canvas.drawCircle(
        m,
        260,
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.accent.withOpacity(0.12),
            AppColors.accent.withOpacity(0),
          ]).createShader(Rect.fromCircle(center: m, radius: 260)),
      );
      final ml = Paint()..strokeWidth = 0.8;
      for (final p in pts) {
        final d = (p - m).distance;
        if (d < 180) {
          ml.color = AppColors.secondary.withOpacity(0.35 * (1 - d / 180));
          canvas.drawLine(p, m, ml);
        }
      }
    }

    // Subtle grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const step = 64.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => false;
}

/// Frosted glass container used by cards and the nav bar.
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? borderColor;
  final double blur;
  final BoxConstraints? constraints;

  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.borderColor,
    this.blur = 0,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      constraints: constraints,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(blur > 0 ? 0.55 : 0.72),
        borderRadius: radius,
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
    if (blur <= 0) return box;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: box,
      ),
    );
  }
}
