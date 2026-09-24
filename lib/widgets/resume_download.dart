import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../utils/file_download.dart';
import 'common.dart';

/// Opens the animated download dialog and starts downloading the resume.
Future<void> downloadResume(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Downloading resume',
    barrierColor: Colors.black.withOpacity(0.65),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const _ResumeDownloadDialog(),
    transitionBuilder: (_, anim, __, child) {
      final a = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(a), child: child),
      );
    },
  );
}

enum _Stage { loading, done, failed }

class _ResumeDownloadDialog extends StatefulWidget {
  const _ResumeDownloadDialog();

  @override
  State<_ResumeDownloadDialog> createState() => _ResumeDownloadDialogState();
}

class _ResumeDownloadDialogState extends State<_ResumeDownloadDialog>
    with TickerProviderStateMixin {
  // Spinning ring
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  // Visible progress (animated toward the real progress, so it looks smooth
  // even though a 40 KB file downloads almost instantly).
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  // Success tick
  late final AnimationController _tick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  _Stage _stage = _Stage.loading;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _stage = _Stage.loading);
    _progress.value = 0;
    _tick.value = 0;
    // Fake-but-honest pacing: bar moves to 85% while the real request runs,
    // then completes once the file is actually ready.
    final pacing = _progress.animateTo(0.85, curve: Curves.easeOutCubic);
    try {
      await Future.wait([
        downloadFile(
          PortfolioData.resumeUrl,
          PortfolioData.resumeFileName,
        ),
        pacing,
      ]);
      await _progress.animateTo(1,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
      if (!mounted) return;
      setState(() => _stage = _Stage.done);
      await _tick.forward();
      await Future.delayed(const Duration(milliseconds: 1100));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _stage = _Stage.failed);
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _progress.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 60,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_spin, _progress, _tick]),
                  builder: (context, _) => CustomPaint(
                    painter: _RingPainter(
                      spin: _spin.value,
                      progress: _progress.value,
                      stage: _stage,
                    ),
                    child: Center(child: _centerIcon()),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  switch (_stage) {
                    _Stage.loading => 'Preparing your download…',
                    _Stage.done => 'Resume downloaded',
                    _Stage.failed => 'Download failed',
                  },
                  key: ValueKey(_stage),
                  style: AppTheme.display(20, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => Text(
                  switch (_stage) {
                    _Stage.loading =>
                      '${(_progress.value * 100).round()}%  ·  ${PortfolioData.resumeFileName}',
                    _Stage.done => 'Check your Downloads folder.',
                    _Stage.failed => 'Please check your connection and try again.',
                  },
                  textAlign: TextAlign.center,
                  style: AppTheme.mono(12, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 22),
              // Linear bar under the ring
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => Stack(
                      children: [
                        Container(color: AppColors.border),
                        FractionallySizedBox(
                          widthFactor: _progress.value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _stage == _Stage.failed
                                  ? const LinearGradient(colors: [
                                      Color(0xFFFF6B6B),
                                      Color(0xFFFF6B9D),
                                    ])
                                  : AppColors.gradient,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_stage == _Stage.failed) ...[
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    GlowButton(label: 'Try again', onTap: _start),
                    GlowButton(
                      label: 'Close',
                      filled: false,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerIcon() {
    switch (_stage) {
      case _Stage.loading:
        // PDF icon gently bobbing
        final bob = math.sin(_spin.value * 2 * math.pi) * 4;
        return Transform.translate(
          offset: Offset(0, bob),
          child: const Icon(Icons.picture_as_pdf_rounded,
              size: 42, color: AppColors.text),
        );
      case _Stage.done:
        final t = Curves.easeOutBack.transform(_tick.value);
        return Transform.scale(
          scale: t,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient,
            ),
            child: const Icon(Icons.check_rounded, size: 38, color: Colors.white),
          ),
        );
      case _Stage.failed:
        return const Icon(Icons.error_outline_rounded,
            size: 46, color: Color(0xFFFF6B6B));
    }
  }
}

class _RingPainter extends CustomPainter {
  final double spin;
  final double progress;
  final _Stage stage;
  _RingPainter({required this.spin, required this.progress, required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Track
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = AppColors.border,
    );

    // Progress arc
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: stage == _Stage.failed
              ? const [Color(0xFFFF6B6B), Color(0xFFFF6B9D), Color(0xFFFF6B6B)]
              : const [AppColors.primary, AppColors.accent, AppColors.secondary, AppColors.primary],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );

    // Orbiting glow dot while loading
    if (stage == _Stage.loading) {
      final a = spin * 2 * math.pi - math.pi / 2;
      final p = c + Offset(math.cos(a), math.sin(a)) * (r + 12);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = AppColors.secondary
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.spin != spin || old.progress != progress || old.stage != stage;
}
