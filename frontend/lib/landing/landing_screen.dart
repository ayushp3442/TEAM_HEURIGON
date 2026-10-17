import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

// ---------------------------------------------------------------------------
// Landing Page Theme Tokens
// Dedicated dark theme for the high-impact photo landing page.
// ---------------------------------------------------------------------------
class _LandingTheme {
  static const Color background = Color(0xFF0B0B0D);
  static const Color surface = Color(0xFF141418);
  static const Color border = Color(0x22FFFFFF);
  static const Color amber = Color(0xFFF5A623);
  static const Color ink = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFA0A0A5);

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFD98205)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _solutionKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/landing/hero.jpg'), context).catchError((e) {
      debugPrint('Notice: Failed to precache assets/landing/hero.jpg: $e');
    });
    precacheImage(const AssetImage('assets/landing/solution.jpg'), context).catchError((e) {
      debugPrint('Notice: Failed to precache assets/landing/solution.jpg: $e');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSolution() {
    final ctx = _solutionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Title(
      title: 'Peer Tutor | Ask a senior before the exam starts',
      color: _LandingTheme.amber,
      child: Scaffold(
        backgroundColor: _LandingTheme.background,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation Bar
              _buildTopBar(context, isMobile),

              // 1. Hero Section
              _buildHeroSection(context, size, isMobile),

              // 2. Solution / "How It Works" Section
              _buildSolutionSection(context, size, isMobile),

              // 3. Footer
              _buildFooter(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Container(
      color: _LandingTheme.background,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo & Monogram
          InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _LandingTheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _LandingTheme.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'PT',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: _LandingTheme.amber,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'StudyCircle',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _LandingTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Auth Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Log in'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _LandingTheme.amber,
                  side: const BorderSide(color: _LandingTheme.amber, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Hero Section (hero.jpg)
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection(BuildContext context, Size size, bool isMobile) {
    // Full viewport height
    final heroHeight = size.height;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo: hero.jpg with alignment: bottomCenter so faces stay visible
          RepaintBoundary(
            child: Image.asset(
              'assets/landing/hero.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              semanticLabel:
                  'Two college students in a library, one stuck on a problem and a senior explaining it',
              errorBuilder: (context, error, stackTrace) {
                debugPrint(
                  'Warning: assets/landing/hero.jpg not found; falling back to #0B0B0D.',
                );
                return Container(color: _LandingTheme.background);
              },
            ),
          ),

          // Gradient Overlay
          // Desktop: 70% black top, 55% middle, 88% bottom
          // Mobile (< 800px): about 80% throughout for maximum text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isMobile
                      ? [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.90),
                        ]
                      : [
                          Colors.black.withValues(alpha: 0.70),
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.88),
                        ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Hero Content: placed in center within the top 60% of the hero
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isMobile ? double.infinity : heroHeight * 0.60,
                maxWidth: 1000,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isMobile ? 32 : 56,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 2-line Headline
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome to',
                              style: GoogleFonts.inter(
                                fontSize: isMobile ? 42 : 92,
                                fontWeight: FontWeight.w800,
                                color: _LandingTheme.ink,
                                height: 1.05,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Peer ',
                                  style: GoogleFonts.inter(
                                    fontSize: isMobile ? 42 : 92,
                                    fontWeight: FontWeight.w800,
                                    color: _LandingTheme.ink,
                                    height: 1.05,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      _LandingTheme.amberGradient.createShader(bounds),
                                  child: Text(
                                    'Tutor',
                                    style: GoogleFonts.inter(
                                      fontSize: isMobile ? 42 : 92,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Subtitle with italic word "before"
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 18 : 28,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.92),
                            height: 1.3,
                          ),
                          children: const [
                            TextSpan(text: 'Ask a senior '),
                            TextSpan(
                              text: 'before',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                color: _LandingTheme.amber,
                              ),
                            ),
                            TextSpan(text: ' the exam starts.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Muted Paragraph (max width 700)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Text(
                          'Find seniors from your own college, book a free slot, and keep chatting for 24 hours after the session.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w400,
                            color: _LandingTheme.muted,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action Buttons
                      if (isMobile)
                        // Mobile: stacked and full width
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAmberGradientButton(
                              context: context,
                              label: 'Find a Senior Tutor',
                              hasArrow: true,
                              onPressed: () => context.go('/register?role=student'),
                            ),
                            const SizedBox(height: 12),
                            _buildMutedDarkButton(
                              label: 'See How It Works',
                              onPressed: _scrollToSolution,
                            ),
                            const SizedBox(height: 14),
                            _buildBecomeTutorLink(context),
                          ],
                        )
                      else
                        // Desktop: side by side
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 12,
                              children: [
                                _buildAmberGradientButton(
                                  context: context,
                                  label: 'Find a Senior Tutor',
                                  hasArrow: true,
                                  onPressed: () => context.go('/register?role=student'),
                                ),
                                _buildMutedDarkButton(
                                  label: 'See How It Works',
                                  onPressed: _scrollToSolution,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildBecomeTutorLink(context),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Solution Section (solution.jpg)
  // ---------------------------------------------------------------------------
  Widget _buildSolutionSection(BuildContext context, Size size, bool isMobile) {
    final minHeight = size.height * 0.90;

    if (isMobile) {
      // Mobile: Image on top (aspect ratio 16:9, radius 12), text below on dark background
      return Container(
        key: _solutionKey,
        color: _LandingTheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/landing/solution.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    semanticLabel:
                        'A senior student explaining a diagram to a relieved first-year student',
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                        'Warning: assets/landing/solution.jpg not found; falling back to #0B0B0D.',
                      );
                      return Container(color: _LandingTheme.surface);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'A senior has already solved this.',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _LandingTheme.ink,
                height: 1.25,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),
            _buildStepRow(1, 'Search by subject, mode and date.'),
            const SizedBox(height: 18),
            _buildStepRow(2, 'Request a slot with a short message.'),
            const SizedBox(height: 18),
            _buildStepRow(3, 'Meet online or on campus, then chat for 24 hours.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _buildAmberGradientButton(
                context: context,
                label: 'Find a Senior Tutor',
                hasArrow: true,
                onPressed: () => context.go('/register?role=student'),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop (>= 800px):
    // Full width with solution.jpg aligned right and left 45% text content
    return Container(
      key: _solutionKey,
      constraints: BoxConstraints(minHeight: minHeight),
      width: double.infinity,
      color: _LandingTheme.background,
      child: Stack(
        children: [
          // Background photo: solution.jpg with alignment: centerRight
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                'assets/landing/solution.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                semanticLabel:
                    'A senior student explaining a diagram to a relieved first-year student',
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Warning: assets/landing/solution.jpg not found; falling back to #0B0B0D.',
                  );
                  return Container(color: _LandingTheme.background);
                },
              ),
            ),
          ),

          // Gradient overlay from left to right:
          // black 92% at left, 70% at 40% width, 0% at 70% width
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.40, 0.70, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Left 45% text content so it never covers the faces on the right
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 72),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A senior has already solved this.',
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: _LandingTheme.ink,
                        height: 1.2,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildStepRow(1, 'Search by subject, mode and date.'),
                    const SizedBox(height: 22),
                    _buildStepRow(2, 'Request a slot with a short message.'),
                    const SizedBox(height: 22),
                    _buildStepRow(3, 'Meet online or on campus, then chat for 24 hours.'),
                    const SizedBox(height: 44),
                    _buildAmberGradientButton(
                      context: context,
                      label: 'Find a Senior Tutor',
                      hasArrow: true,
                      onPressed: () => context.go('/register?role=student'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step Row
  // ---------------------------------------------------------------------------
  Widget _buildStepRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _LandingTheme.amber.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: _LandingTheme.amber, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _LandingTheme.amber,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Action Button Helpers
  // ---------------------------------------------------------------------------
  Widget _buildAmberGradientButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    bool hasArrow = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: _LandingTheme.amberGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _LandingTheme.amber.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              if (hasArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.black),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMutedDarkButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        side: const BorderSide(color: Color(0x33FFFFFF), width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBecomeTutorLink(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/register?role=tutor'),
      style: TextButton.styleFrom(
        foregroundColor: _LandingTheme.amber,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        'Become a tutor',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _LandingTheme.amber,
          decoration: TextDecoration.underline,
          decorationColor: _LandingTheme.amber,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Footer
  // ---------------------------------------------------------------------------
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      color: _LandingTheme.background,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 56,
        vertical: 36,
      ),
      child: Column(
        children: [
          const Divider(height: 1, color: _LandingTheme.border),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$kAppName © 2026',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _LandingTheme.muted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => context.go('/privacy'),
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _LandingTheme.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () => context.go('/terms'),
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _LandingTheme.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
