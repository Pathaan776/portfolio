import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/common.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  static const _icons = [
    Icons.phone_iphone_rounded,
    Icons.account_tree_rounded,
    Icons.cloud_sync_rounded,
    Icons.rocket_launch_rounded,
  ];
  static const _colors = [
    AppColors.secondary,
    AppColors.primary,
    AppColors.accent,
    Color(0xFFFF6B9D),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1100 ? 4 : (w >= 720 ? 2 : 1);
    final entries = PortfolioData.skills.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          index: '04',
          title: 'Skills & tools',
          subtitle: 'What I use at work almost every day.',
        ),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, c) {
          const gap = 20.0;
          final cardW = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < entries.length; i++)
                SizedBox(
                  width: cardW,
                  child: Reveal(
                    delay: Duration(milliseconds: 120 * i),
                    child: _SkillCard(
                      title: entries[i].key,
                      skills: entries[i].value,
                      icon: _icons[i % _icons.length],
                      color: _colors[i % _colors.length],
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 56),
        const _Marquee(),
      ],
    );
  }
}

class _SkillCard extends StatefulWidget {
  final String title;
  final List<String> skills;
  final IconData icon;
  final Color color;
  const _SkillCard({
    required this.title,
    required this.skills,
    required this.icon,
    required this.color,
  });

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_hover ? 0.25 : 0),
              blurRadius: 36,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Glass(
          constraints: const BoxConstraints(minHeight: 300),
          borderColor: _hover ? widget.color.withOpacity(0.7) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: widget.color, size: 30),
              const SizedBox(height: 16),
              Text(widget.title,
                  style: AppTheme.display(20, weight: FontWeight.w700)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < widget.skills.length; i++)
                    _PopIn(
                      index: i,
                      child: TagChip(widget.skills[i], color: widget.color),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chips pop in one after another once their card is revealed.
class _PopIn extends StatefulWidget {
  final int index;
  final Widget child;
  const _PopIn({required this.index, required this.child});

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> {
  bool _on = false;
  Animation<double>? _reveal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reveal?.removeListener(_listen);
    _reveal = Reveal.of(context);
    if (_reveal == null) {
      _on = true;
    } else {
      _reveal!.addListener(_listen);
    }
  }

  void _listen() {
    if (_on || (_reveal?.value ?? 0) <= 0) return;
    _reveal?.removeListener(_listen);
    Future.delayed(Duration(milliseconds: 250 + 60 * widget.index), () {
      if (mounted) setState(() => _on = true);
    });
  }

  @override
  void dispose() {
    _reveal?.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _on ? 1 : 0.4,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: _on ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: widget.child,
      ),
    );
  }
}

/// Endless horizontally scrolling strip of tech names.
class _Marquee extends StatefulWidget {
  const _Marquee();

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  static const _items = [
    'Flutter', 'Dart', 'BLoC', 'Riverpod', 'GetX', 'Firebase', 'REST',
    'Clean Architecture', 'Flutter Web', 'Android', 'iOS', 'CI/CD',
    'Payments', 'KYC', 'Web3', 'Animations',
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _strip() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in _items) ...[
          Text(s,
              style: AppTheme.display(28, weight: FontWeight.w700)
                  .copyWith(color: AppColors.text.withOpacity(0.18))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Icon(Icons.flutter_dash, color: AppColors.primary, size: 22),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ShaderMask(
        shaderCallback: (r) => const LinearGradient(colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ], stops: [0, 0.1, 0.9, 1]).createShader(r),
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) => FractionalTranslation(
                translation: Offset(-_c.value / 2, 0),
                child: child,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [_strip(), _strip()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
