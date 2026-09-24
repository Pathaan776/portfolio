import 'package:flutter/material.dart';

import 'data/portfolio_data.dart';
import 'sections/about_section.dart';
import 'sections/contact_section.dart';
import 'sections/experience_section.dart';
import 'sections/hero_section.dart';
import 'sections/projects_section.dart';
import 'sections/skills_section.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_background.dart';
import 'widgets/nav_bar.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${PortfolioData.name} · Senior Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();
  final _mouse = ValueNotifier<Offset?>(null);

  final _heroKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _expKey = GlobalKey();
  final _workKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _contactKey = GlobalKey();

  late final _sectionKeys = [_aboutKey, _expKey, _workKey, _skillsKey, _contactKey];

  int _active = -1;
  double _progress = 0;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _mouse.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scroll.position;
    final progress =
        pos.maxScrollExtent <= 0 ? 0.0 : pos.pixels / pos.maxScrollExtent;
    final scrolled = pos.pixels > 40;

    final screenH = MediaQuery.sizeOf(context).height;
    var active = -1;
    for (var i = 0; i < _sectionKeys.length; i++) {
      final ctx = _sectionKeys[i].currentContext;
      final box = ctx?.findRenderObject();
      if (box is RenderBox && box.attached) {
        final top = box.localToGlobal(Offset.zero).dy;
        if (top < screenH * 0.4) active = i;
      }
    }

    if (active != _active ||
        scrolled != _scrolled ||
        (progress - _progress).abs() > 0.002) {
      setState(() {
        _active = active;
        _scrolled = scrolled;
        _progress = progress;
      });
    }
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _section(GlobalKey key, Widget child, {double top = 110}) {
    return Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(
        Responsive.hPad(context),
        top,
        Responsive.hPad(context),
        40,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      NavItem('About', () => _goTo(_aboutKey)),
      NavItem('Experience', () => _goTo(_expKey)),
      NavItem('Work', () => _goTo(_workKey)),
      NavItem('Skills', () => _goTo(_skillsKey)),
      NavItem('Contact', () => _goTo(_contactKey)),
    ];

    return Scaffold(
      body: MouseRegion(
        opaque: false,
        onHover: (e) => _mouse.value = e.position,
        onExit: (_) => _mouse.value = null,
        child: Stack(
          children: [
            Positioned.fill(child: AnimatedBackground(mouse: _mouse)),
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KeyedSubtree(
                      key: _heroKey,
                      child: HeroSection(
                        mouse: _mouse,
                        onViewWork: () => _goTo(_workKey),
                        onContact: () => _goTo(_contactKey),
                      ),
                    ),
                    _section(_aboutKey, const AboutSection(), top: 60),
                    _section(_expKey, const ExperienceSection()),
                    _section(_workKey, const ProjectsSection()),
                    _section(_skillsKey, const SkillsSection()),
                    _section(_contactKey, const ContactSection()),
                    const Footer(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: NavBar(
                    items: navItems,
                    active: _active,
                    progress: _progress,
                    scrolled: _scrolled,
                    onLogo: () => _goTo(_heroKey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
