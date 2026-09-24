import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/resume_download.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Column(
      children: [
        const SectionHeader(index: '05', title: "What's next?"),
        const SizedBox(height: 48),
        Reveal(
          child: _GlowPanel(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 24 : 64,
                vertical: mobile ? 44 : 72,
              ),
              child: Column(
                children: [
                  GradientText(
                    "Let's build something\ngreat together.",
                    align: TextAlign.center,
                    style: AppTheme.display(mobile ? 34 : 58),
                  ),
                  const SizedBox(height: 22),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: const Text(
                      "If you are hiring a Flutter developer, or someone to lead "
                      "a small mobile team, I'd love to hear from you. Email, "
                      'call or WhatsApp, whichever is easier. I try to reply '
                      'within a day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.muted, fontSize: 17, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      GlowButton(
                        label: 'Say hello',
                        icon: Icons.send_rounded,
                        onTap: () => openUrl('mailto:${PortfolioData.email}'),
                      ),
                      GlowButton(
                        label: 'Call me',
                        icon: Icons.call_rounded,
                        filled: false,
                        onTap: () => openUrl(PortfolioData.phoneDial),
                      ),
                      GlowButton(
                        label: 'WhatsApp',
                        icon: Icons.chat_rounded,
                        filled: false,
                        onTap: () => openUrl(PortfolioData.whatsApp),
                      ),
                      GlowButton(
                        label: 'LinkedIn',
                        icon: Icons.work_outline_rounded,
                        filled: false,
                        onTap: () => openUrl(PortfolioData.linkedIn),
                      ),
                      GlowButton(
                        label: 'Download resume',
                        icon: Icons.download_rounded,
                        filled: false,
                        onTap: () => downloadResume(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _CopyText(
                        text: PortfolioData.email,
                        icon: Icons.mail_outline_rounded,
                      ),
                      _CopyText(
                        text: PortfolioData.phone,
                        icon: Icons.phone_iphone_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Panel with a slowly rotating gradient border.
class _GlowPanel extends StatefulWidget {
  final Widget child;
  const _GlowPanel({required this.child});

  @override
  State<_GlowPanel> createState() => _GlowPanelState();
}

class _GlowPanelState extends State<_GlowPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
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
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: widget.child,
      ),
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: SweepGradient(
            transform: GradientRotation(_c.value * 6.2831853),
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.secondary,
              Colors.transparent,
              AppColors.primary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 60,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Shows a value (email / phone); tap to copy it.
class _CopyText extends StatefulWidget {
  final String text;
  final IconData icon;
  const _CopyText({required this.text, required this.icon});

  @override
  State<_CopyText> createState() => _CopyTextState();
}

class _CopyTextState extends State<_CopyText> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _copy,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Row(
            key: ValueKey(_copied),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _copied ? Icons.check_rounded : widget.icon,
                size: 16,
                color: _copied ? AppColors.secondary : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _copied ? 'Copied!' : widget.text,
                  style: AppTheme.mono(14,
                      color: _copied ? AppColors.secondary : AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.work_outline_rounded,
                tooltip: 'LinkedIn',
                onTap: () => openUrl(PortfolioData.linkedIn),
              ),
              _SocialIcon(
                icon: Icons.mail_outline_rounded,
                tooltip: 'Email',
                onTap: () => openUrl('mailto:${PortfolioData.email}'),
              ),
              _SocialIcon(
                icon: Icons.description_outlined,
                tooltip: 'Download resume',
                onTap: () => downloadResume(context),
              ),
              _SocialIcon(
                icon: Icons.call_rounded,
                tooltip: PortfolioData.phone,
                onTap: () => openUrl(PortfolioData.phoneDial),
              ),
              _SocialIcon(
                icon: Icons.shop_rounded,
                tooltip: 'Pay10 UAE on Google Play',
                onTap: () => openUrl(PortfolioData.playStore),
              ),
              if (PortfolioData.github != null)
                _SocialIcon(
                  icon: Icons.code_rounded,
                  tooltip: 'GitHub',
                  onTap: () => openUrl(PortfolioData.github!),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Designed & built with ',
                  style: AppTheme.mono(12, color: AppColors.muted)),
              const Icon(Icons.flutter_dash, size: 16, color: AppColors.accent),
              Text(' Flutter by ${PortfolioData.name}',
                  style: AppTheme.mono(12, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hover
                  ? AppColors.primary.withOpacity(0.18)
                  : Colors.transparent,
              border: Border.all(
                  color: _hover ? AppColors.primary : AppColors.border),
            ),
            child: Icon(widget.icon,
                size: 20, color: _hover ? AppColors.text : AppColors.muted),
          ),
        ),
      ),
    );
  }
}
