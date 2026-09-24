import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A little live "wallet app" drawn entirely in Flutter, inside a phone frame
/// that tilts in 3D toward the mouse. Nods to the Pay10 wallet work.
class PhoneMockup extends StatefulWidget {
  final ValueNotifier<Offset?> mouse;
  const PhoneMockup({super.key, required this.mouse});

  @override
  State<PhoneMockup> createState() => _PhoneMockupState();
}

class _PhoneMockupState extends State<PhoneMockup>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  Offset _tiltFor(Offset? m) {
    if (m == null) return Offset.zero;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return Offset.zero;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final screen = MediaQuery.sizeOf(context);
    final dx = ((m.dx - center.dx) / screen.width).clamp(-1.0, 1.0);
    final dy = ((m.dy - center.dy) / screen.height).clamp(-1.0, 1.0);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset?>(
      valueListenable: widget.mouse,
      builder: (context, m, child) {
        final target = _tiltFor(m);
        return TweenAnimationBuilder<Offset>(
          tween: Tween(end: target),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, tilt, child) {
            return AnimatedBuilder(
              animation: _loop,
              child: child,
              builder: (context, child) {
                final bob = math.sin(_loop.value * 2 * math.pi) * 8;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..translate(0.0, bob)
                    ..rotateY(tilt.dx * 0.45 - 0.12)
                    ..rotateX(-tilt.dy * 0.35 + 0.04),
                  child: child,
                );
              },
            );
          },
          child: child,
        );
      },
      child: SizedBox(
        width: 380,
        height: 600,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _phone(),
            _FloatingBadge(
              anim: _loop,
              phase: 0,
              left: -10,
              top: 90,
              icon: Icons.speed_rounded,
              label: '60 FPS',
              color: AppColors.secondary,
            ),
            _FloatingBadge(
              anim: _loop,
              phase: 0.33,
              right: -6,
              top: 220,
              icon: Icons.layers_rounded,
              label: 'Clean Arch',
              color: AppColors.primary,
            ),
            _FloatingBadge(
              anim: _loop,
              phase: 0.66,
              left: 0,
              bottom: 90,
              icon: Icons.verified_user_rounded,
              label: 'KYC · OCR',
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _phone() {
    return Container(
      width: 280,
      height: 570,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B28),
        borderRadius: BorderRadius.circular(46),
        border: Border.all(color: const Color(0xFF34344A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 80,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          color: const Color(0xFF0B0B14),
          child: AnimatedBuilder(
            animation: Listenable.merge([_intro, _loop]),
            builder: (context, _) => _screen(),
          ),
        ),
      ),
    );
  }

  double _stagger(double start, double end) {
    final t = ((_intro.value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  Widget _screen() {
    final balance = 24850.75 * _stagger(0.15, 0.7);
    final shimmer = _loop.value;

    Widget appear(double s, double e, Widget child) {
      final v = _stagger(s, e);
      return Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // status bar + notch
          Row(
            children: [
              const Text('9:41',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                width: 70,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Spacer(),
              const Icon(Icons.signal_cellular_alt_rounded, size: 12),
              const SizedBox(width: 4),
              const Icon(Icons.battery_full_rounded, size: 12),
            ],
          ),
          const SizedBox(height: 18),
          appear(
            0.0,
            0.3,
            const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text('R',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good evening',
                        style: TextStyle(fontSize: 10, color: AppColors.muted)),
                    Text('Rahish',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                Spacer(),
                Icon(Icons.notifications_none_rounded, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // balance card with moving shine
          appear(
            0.1,
            0.45,
            Container(
              height: 132,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A4DFF), Color(0xFF3A8BFF), Color(0xFF00C2A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FractionalTranslation(
                        translation: Offset(-1.5 + 3 * shimmer, 0),
                        child: Transform.rotate(
                          angle: 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total balance',
                            style: TextStyle(fontSize: 11, color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(
                          'AED ${balance.toStringAsFixed(2)}',
                          style: AppTheme.display(24).copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Text('•••• 4821',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    letterSpacing: 1.5)),
                            Spacer(),
                            Icon(Icons.contactless_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          appear(
            0.3,
            0.6,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _action(Icons.qr_code_scanner_rounded, 'Scan & Pay',
                    AppColors.secondary, 0),
                _action(Icons.send_rounded, 'Send', AppColors.primary, 0.25),
                _action(Icons.account_balance_rounded, 'Link Bank',
                    AppColors.accent, 0.5),
                _action(Icons.badge_rounded, 'KYC', const Color(0xFFFF6B9D), 0.75),
              ],
            ),
          ),
          const SizedBox(height: 20),
          appear(
            0.45,
            0.7,
            const Text('Recent activity',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          appear(0.55, 0.8,
              _txn('Coffee Bean', 'Scan & Pay', '-18.50', Icons.local_cafe_rounded)),
          appear(0.65, 0.9,
              _txn('Salary', 'Bank transfer', '+12,000', Icons.work_rounded)),
          appear(0.75, 1.0,
              _txn('Careem', 'Wallet', '-42.00', Icons.local_taxi_rounded)),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, double phase) {
    final pulse = (math.sin((_loop.value + phase) * 2 * math.pi) + 1) / 2;
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12 + 0.08 * pulse),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
      ],
    );
  }

  Widget _txn(String title, String sub, String amount, IconData icon) {
    final positive = amount.startsWith('+');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.muted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
                Text(sub,
                    style: const TextStyle(fontSize: 9, color: AppColors.muted)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.secondary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final Animation<double> anim;
  final double phase;
  final double? left, right, top, bottom;
  final IconData icon;
  final String label;
  final Color color;

  const _FloatingBadge({
    required this.anim,
    required this.phase,
    required this.icon,
    required this.label,
    required this.color,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, child) {
          final y = math.sin((anim.value + phase) * 2 * math.pi) * 10;
          return Transform.translate(offset: Offset(0, y), child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.25), blurRadius: 20),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
