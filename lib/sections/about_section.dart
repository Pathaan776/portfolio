import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/common.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;

    final text = Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PortfolioData.about,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 17,
              height: 1.75,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: const [
              _Info(Icons.location_on_outlined, PortfolioData.location),
              _Info(Icons.work_outline_rounded, 'FinTech · Web3 · E-commerce'),
              _Info(Icons.timer_outlined, 'Can join in 15 days'),
            ],
          ),
        ],
      ),
    );

    final stats = LayoutBuilder(
      builder: (context, c) {
        const gap = 16.0;
        final cardW = ((c.maxWidth - gap) / 2).floorToDouble();
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < PortfolioData.stats.length; i++)
              SizedBox(
                width: cardW,
                height: 150,
                child: Reveal(
                  delay: Duration(milliseconds: 120 * i),
                  child: _StatCard(PortfolioData.stats[i]),
                ),
              ),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(index: '01', title: 'About me'),
        const SizedBox(height: 40),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: text),
              const SizedBox(width: 56),
              Expanded(flex: 5, child: stats),
            ],
          )
        else ...[
          text,
          const SizedBox(height: 32),
          stats,
        ],
      ],
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.text, fontSize: 14)),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final Stat stat;
  const _StatCard(this.stat);

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;
  bool _go = false;
  Animation<double>? _reveal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reveal?.removeListener(_onReveal);
    _reveal = Reveal.of(context);
    if (_reveal == null) {
      _go = true;
    } else {
      _reveal!.addListener(_onReveal);
    }
  }

  void _onReveal() {
    if (!_go && (_reveal?.value ?? 0) > 0 && mounted) {
      setState(() => _go = true);
    }
  }

  @override
  void dispose() {
    _reveal?.removeListener(_onReveal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.04 : 1,
        duration: const Duration(milliseconds: 250),
        child: Glass(
          borderColor: _hover ? AppColors.primary : null,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Count-up animation (starts when the Reveal parent fades in)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 0.0,
                    end: _go ? widget.stat.value.toDouble() : 0.0),
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOutExpo,
                builder: (_, v, __) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: GradientText(
                    '${v.round()}${widget.stat.suffix}',
                    style: AppTheme.display(44),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.stat.label,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
