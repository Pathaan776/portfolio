import 'package:flutter/material.dart';

/// Everything shown on the site lives here.
/// Change text / links in this one file — no need to touch the UI code.
class PortfolioData {
  static const name = 'Rahish Khan';
  static const firstName = 'Rahish';
  static const roles = [
    'Senior Flutter Developer',
    'Mobile Team Lead',
    'FinTech App Builder',
    'Web3 Wallet Engineer',
  ];
  static const tagline =
      "I've been building Flutter apps for six years. Right now I lead the "
      'mobile team at Pay10, where our UAE wallet is live on the Play Store '
      'and the App Store.';
  static const location = 'Delhi NCR, India';

  static const email = 'khanrahish776@gmail.com';
  static const phone = '+91 99588 01488';
  static const phoneDial = 'tel:+919958801488';
  static const whatsApp = 'https://wa.me/919958801488';
  static const linkedIn = 'https://www.linkedin.com/in/rahish-khan/';
  // Add your GitHub URL here when you want it public, e.g. 'https://github.com/yourname'
  static const String? github = null;
  // Put a resume PDF at web/resume.pdf and it will be served at /resume.pdf
  static const resumeUrl = 'resume.pdf';

  static const playStore =
      'https://play.google.com/store/apps/details?id=ae.payten.wallet.app';
  static const appStore = 'https://apps.apple.com/in/app/pay10-uae/id6739810874';

  static const about =
      'I started working with Flutter in 2020 at Quick Web Codes, a small '
      'agency in Ghaziabad. In four years there I built whatever clients '
      'needed: crypto wallets, trading bots, token apps, online stores and '
      'direct-selling apps. The one I am proudest of is KOOP Wallet, a '
      'non-custodial wallet that works with 7 blockchains and keeps private '
      'keys on the phone.\n\n'
      'In 2024 I joined Pay10. I lead a team of four developers and look after '
      'the Pay10 UAE wallet from the first commit to the store release. Scan & '
      'Pay, fund transfers, bank linking and Emirates ID KYC all went through '
      'my hands, and about 2,000 people use the app today. We got our NPCI '
      'licence in August 2026, so now I am building Pay10 India.\n\n'
      'The part I enjoy most is taking a messy requirement and turning it into '
      'an app that feels simple to use and is easy for the next developer to '
      'work on.';

  static const stats = [
    Stat(6, '+', 'Years of Flutter'),
    Stat(50, '+', 'Apps shipped'),
    Stat(2000, '+', 'Active wallet users'),
    Stat(4, '', 'Developers led'),
  ];

  static const experience = [
    Experience(
      role: 'Flutter Developer · Team Lead',
      company: 'Pay10',
      place: 'Delhi',
      period: 'May 2024 – Present',
      points: [
        'I lead a team of 4 Flutter developers. I review their code, plan '
            'sprints and help the newer folks when they get stuck.',
        'I built and look after the Pay10 UAE wallet. It is live on Google '
            'Play and the App Store with around 2,000 active users.',
        'I worked on Scan & Pay, fund transfers, bank account linking and a '
            'KYC flow that reads the Emirates ID with OCR.',
        'We got the NPCI licence in August 2026, and I am now building the '
            'India version of the app.',
        'I handle Play Store and App Store releases and send UAT builds to '
            'testers through Firebase App Distribution.',
      ],
    ),
    Experience(
      role: 'Flutter Developer',
      company: 'Quick Web Codes',
      place: 'Ghaziabad',
      period: 'Jan 2020 – May 2024',
      points: [
        'Built KOOP Wallet, a non-custodial crypto wallet for 7 chains '
            'including BTC, ETH and BSC.',
        'Worked on Trust Coin and ZZNEX BOT, two crypto trading bots where '
            'users set their own risk limits.',
        'Made apps for token projects, online stores and direct-selling '
            'businesses with referral and commission tracking.',
        'Hooked apps up to payment gateways, REST APIs and third-party SDKs '
            'for many different clients.',
      ],
    ),
  ];

  static const projects = [
    Project(
      title: 'Pay10 UAE',
      subtitle: 'Consumer digital wallet · Live',
      description:
          'A digital wallet for people in the UAE. You can scan a QR to pay, '
          'send money, link your bank account and finish KYC by scanning your '
          'Emirates ID. I have worked on it since day one and it is live on '
          'both stores.',
      tags: ['Flutter', 'BLoC', 'GetX', 'Firebase', 'KYC', 'Payments'],
      icon: Icons.account_balance_wallet_rounded,
      accent: Color(0xFF7C5CFF),
      links: [
        ProjectLink('Google Play', playStore, Icons.shop_rounded),
        ProjectLink('App Store', appStore, Icons.apple),
      ],
      featured: true,
    ),
    Project(
      title: 'KOOP Wallet',
      subtitle: 'Non-custodial Web3 wallet',
      description:
          'A crypto wallet that works with 7 chains, including BTC, ETH and '
          'BSC. Private keys never leave the phone, so the user stays in '
          'control of their funds.',
      tags: ['Flutter', 'Web3', 'Security', 'Multi-chain'],
      icon: Icons.token_rounded,
      accent: Color(0xFF00D1B2),
    ),
    Project(
      title: 'Trust Coin',
      subtitle: 'AI crypto trading bot',
      description:
          'A trading bot app where users pick their own risk level and the bot '
          'trades for them. Trade data is encrypted on the way through.',
      tags: ['Flutter', 'REST APIs', 'Realtime'],
      icon: Icons.auto_graph_rounded,
      accent: Color(0xFFFF6B9D),
    ),
    Project(
      title: 'ZZNEX BOT',
      subtitle: '24/7 trading automation',
      description:
          'A bot that trades crypto around the clock. The app shows what it is '
          'doing in real time and sends a notification when something happens.',
      tags: ['Flutter', 'Charts', 'Notifications'],
      icon: Icons.smart_toy_rounded,
      accent: Color(0xFFFFB547),
    ),
    Project(
      title: 'MI Pro (MIToken)',
      subtitle: 'BEP-20 token platform',
      description:
          'App for a BEP-20 token with a fixed supply and a burn feature, so '
          'holders can track the token and use it inside the platform.',
      tags: ['Flutter', 'Blockchain', 'BSC'],
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFF4DA3FF),
    ),
    Project(
      title: 'AYA-Store & Samron Market',
      subtitle: 'E-commerce / direct selling',
      description:
          'Two apps for direct-selling businesses. Sellers can see their '
          'referral tree, track commissions and collect distributor rewards.',
      tags: ['Flutter', 'E-commerce', 'Payments'],
      icon: Icons.storefront_rounded,
      accent: Color(0xFFB76CFF),
    ),
  ];

  static const skills = {
    'Mobile': [
      'Flutter', 'Dart', 'Flutter Web', 'Android', 'iOS', 'Animations',
      'Push Notifications', 'Platform Channels',
    ],
    'Architecture': [
      'BLoC / Cubit', 'GetX', 'Provider', 'Riverpod', 'MVVM',
      'Clean Architecture', 'go_router',
    ],
    'Backend & Data': [
      'REST APIs', 'Firebase', 'Firestore', 'Crashlytics', 'SQLite',
      'Payment Gateways', 'Secure Tokens',
    ],
    'Tools & Delivery': [
      'Git', 'CI/CD', 'Play Store', 'App Store', 'Flutter DevTools',
      'Figma', 'Jira', 'Agile',
    ],
  };
}

class Stat {
  final int value;
  final String suffix;
  final String label;
  const Stat(this.value, this.suffix, this.label);
}

class Experience {
  final String role, company, place, period;
  final List<String> points;
  const Experience({
    required this.role,
    required this.company,
    required this.place,
    required this.period,
    required this.points,
  });
}

class ProjectLink {
  final String label, url;
  final IconData icon;
  const ProjectLink(this.label, this.url, this.icon);
}

class Project {
  final String title, subtitle, description;
  final List<String> tags;
  final IconData icon;
  final Color accent;
  final List<ProjectLink> links;
  final bool featured;
  const Project({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.icon,
    required this.accent,
    this.links = const [],
    this.featured = false,
  });
}
