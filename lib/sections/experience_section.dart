import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/common.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = PortfolioData.experience;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          index: '02',
          title: 'Experience',
          subtitle: 'Two companies, six years and a lot of apps.',
        ),
        const SizedBox(height: 48),
        for (var i = 0; i < items.length; i++)
          Reveal(
            delay: Duration(milliseconds: 150 * i),
            from: const Offset(-40, 0),
            child: _TimelineItem(item: items[i], isLast: i == items.length - 1),
          ),
      ],
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final Experience item;
  final bool isLast;
  const _TimelineItem({required this.item, required this.isLast});

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.item;
    final mobile = Responsive.isMobile(context);
    return Stack(
      children: [
        if (!widget.isLast)
          Positioned(
            left: 15,
            top: 48,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.6),
                    AppColors.border,
                  ],
                ),
              ),
            ),
          ),
        Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // rail dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 26),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(_hover ? 0.9 : 0.5),
                        blurRadius: _hover ? 20 : 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: mobile ? 12 : 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  transform: Matrix4.translationValues(_hover ? 6 : 0, 0, 0),
                  child: Glass(
                    borderColor: _hover ? AppColors.primary.withOpacity(0.7) : null,
                    padding: EdgeInsets.all(mobile ? 20 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(e.role,
                                style: AppTheme.display(mobile ? 20 : 24,
                                    weight: FontWeight.w700)),
                            TagChip(e.period, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '@ ${e.company} · ${e.place}',
                          style: AppTheme.mono(14),
                        ),
                        const SizedBox(height: 18),
                        for (final p in e.points)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(Icons.play_arrow_rounded,
                                      size: 14, color: AppColors.secondary),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 15,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ],
    );
  }
}
