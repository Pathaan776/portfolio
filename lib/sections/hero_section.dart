import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/phone_mockup.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onViewWork;
  final VoidCallback onContact;
  final ValueNotifier<Offset?> mouse;
  const HeroSection({
    super.key,
    required this.onViewWork,
    required this.onContact,
    required this.mouse,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobile = Responsive.isMobile(context);
    final wide = size.width >= 1000;

    final intro = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Reveal(
          delay: const Duration(milliseconds: 100),
          child: _AvailableBadge(),
        ),
        const SizedBox(height: 28),
        Reveal(
          delay: const Duration(milliseconds: 250),
          child: Text(
            "Hi, I'm",
            style: AppTheme.mono(mobile ? 16 : 18, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 8),
        Reveal(
          delay: const Duration(milliseconds: 400),
          child: GradientText(
            PortfolioData.name,
            align: wide ? TextAlign.start : TextAlign.center,
            style: AppTheme.display(mobile ? 52 : (wide ? 88 : 72)),
          ),
        ),
        const SizedBox(height: 16),
        Reveal(
          delay: const Duration(milliseconds: 550),
          child: _Typewriter(
            words: PortfolioData.roles,
            style: AppTheme.display(mobile ? 22 : 32, weight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        Reveal(
          delay: const Duration(milliseconds: 700),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              PortfolioData.tagline,
              textAlign: wide ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: mobile ? 16 : 18,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Reveal(
          delay: const Duration(milliseconds: 850),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: wide ? WrapAlignment.start : WrapAlignment.center,
            children: [
              GlowButton(
                label: 'View my work',
                icon: Icons.arrow_downward_rounded,
                onTap: onViewWork,
              ),
              GlowButton(
                label: 'Get in touch',
                icon: Icons.mail_outline_rounded,
                filled: false,
                onTap: onContact,
              ),
            ],
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.height),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.hPad(context),
          mobile ? 110 : 120,
          Responsive.hPad(context),
          60,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (wide)
              Row(
                children: [
                  Expanded(flex: 6, child: intro),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 4,
                    child: Reveal(
                      delay: const Duration(milliseconds: 600),
                      from: const Offset(60, 0),
                      child: Center(child: PhoneMockup(mouse: mouse)),
                    ),
                  ),
                ],
              )
            else ...[
              intro,
              const SizedBox(height: 60),
              Reveal(
                delay: const Duration(milliseconds: 900),
                child: mobile
                    ? SizedBox(
                        height: 500,
                        child: FittedBox(child: PhoneMockup(mouse: mouse)),
                      )
                    : PhoneMockup(mouse: mouse),
              ),
            ],
            const SizedBox(height: 50),
            const _ScrollHint(),
          ],
        ),
      ),
    );
  }
}

class _AvailableBadge extends StatefulWidget {
  @override
  State<_AvailableBadge> createState() => _AvailableBadgeState();
}

class _AvailableBadgeState extends State<_AvailableBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(painter: _PulsePainter(_c.value)),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Open to new opportunities',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double t;
  _PulsePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      3 + 6 * t,
      Paint()..color = AppColors.secondary.withOpacity(0.5 * (1 - t)),
    );
    canvas.drawCircle(c, 4, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.t != t;
}

/// Types each word, pauses, deletes, moves to the next. Blinking cursor.
class _Typewriter extends StatefulWidget {
  final List<String> words;
  final TextStyle style;
  const _Typewriter({required this.words, required this.style});

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  int _word = 0;
  int _chars = 0;
  bool _deleting = false;
  bool _cursor = true;
  Timer? _timer;
  Timer? _blink;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), _tick);
    _blink = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _cursor = !_cursor);
    });
  }

  void _tick() {
    final word = widget.words[_word];
    Duration next = Duration(milliseconds: _deleting ? 40 : 85);
    setState(() {
      if (!_deleting) {
        _chars++;
        if (_chars >= word.length) {
          _chars = word.length;
          _deleting = true;
          next = const Duration(milliseconds: 1600);
        }
      } else {
        _chars--;
        if (_chars <= 0) {
          _chars = 0;
          _deleting = false;
          _word = (_word + 1) % widget.words.length;
          next = const Duration(milliseconds: 350);
        }
      }
    });
    _timer = Timer(next, () {
      if (mounted) _tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blink?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.words[_word].substring(0, _chars);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('> ', style: widget.style.copyWith(color: AppColors.secondary)),
        Flexible(
          child: Text(text,
              maxLines: 1,
              style: widget.style.copyWith(color: AppColors.text)),
        ),
        Opacity(
          opacity: _cursor ? 1 : 0,
          child: Container(
            width: 3,
            height: (widget.style.fontSize ?? 24) * 1.1,
            margin: const EdgeInsets.only(left: 4),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Container(
          width: 26,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.muted.withOpacity(0.5), width: 1.5),
          ),
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 6 + 14 * Curves.easeInOut.transform(t)),
          child: Opacity(
            opacity: math.max(0.0, 1 - t * 1.2),
            child: Container(
              width: 4,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}
