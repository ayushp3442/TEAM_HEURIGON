import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/brand_logo.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

class Scene0Hero extends StatefulWidget {
  final double overallProgress;

  const Scene0Hero({
    super.key,
    required this.overallProgress,
  });

  @override
  State<Scene0Hero> createState() => _Scene0HeroState();
}

class _Scene0HeroState extends State<Scene0Hero> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    // Scene 0 is active from 0.0 to 0.125
    final p = SceneProgress.raw(0, widget.overallProgress);
    final opacity = (1.0 - (p - 0.7) / 0.3).clamp(0.0, 1.0);
    final zShift = -120.0 * (p.clamp(0.0, 1.0));

    final copyColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StudyCircleLogo(
          height: 44,
          showText: true,
        ),
        const SizedBox(height: AppLayout.space20),
        Text(
          'Stuck on a doubt? Ask a senior who solved it last year.',
          style: tt.displayLarge?.copyWith(
            fontSize: isDesktop ? 36 : 28,
            height: 1.2,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppLayout.space16),
        Text(
          'StudyCircle connects first-year students with senior students from their own college. Pick a subject, choose a time that works, and get your doubt cleared.',
          style: tt.bodyLarge?.copyWith(
            color: AppColors.muted,
            height: 1.5,
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
        const SizedBox(height: AppLayout.space24),
        Wrap(
          spacing: AppLayout.space12,
          runSpacing: AppLayout.space12,
          children: [
            FilledButton(
              onPressed: () => context.go('/register?role=student'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                ),
              ),
              child: const Text('Find a senior tutor'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/register?role=tutor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border, width: AppLayout.borderWidth1),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                ),
              ),
              child: const Text('Become a tutor'),
            ),
          ],
        ),
      ],
    );

    final deskIllustration = MouseTilt(
      child: _TiltedDeskPlane(floatController: _floatController),
    );

    return RepaintBoundary(
      child: Depth3D(
        z: zShift,
        opacity: opacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 11, child: copyColumn),
                        const SizedBox(width: AppLayout.space40),
                        Expanded(flex: 9, child: deskIllustration),
                      ],
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            copyColumn,
                            const SizedBox(height: AppLayout.space20),
                            deskIllustration,
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3D Tilted Desk Plane with textbook, laptop, clock, and floating '?'
// ---------------------------------------------------------------------------
class _TiltedDeskPlane extends StatelessWidget {
  final AnimationController floatController;

  const _TiltedDeskPlane({required this.floatController});

  @override
  Widget build(BuildContext context) {
    // 55 degrees in radians
    const tiltRad = 55.0 * (math.pi / 180.0);

    return SizedBox(
      height: 280,
      width: 360,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Wall Clock (standing upright above the desk)
          Positioned(
            top: 6,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
              ),
              child: CustomPaint(
                painter: _ClockPainter(hours: 11, minutes: 40),
              ),
            ),
          ),

          // Tilted Desk Plane
          Positioned(
            bottom: 12,
            child: Depth3D(
              rotateX: tiltRad,
              child: Container(
                width: 340,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2ECE1), // Subtle warm desk tone
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                  border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                ),
                padding: const EdgeInsets.all(AppLayout.space16),
                child: Stack(
                  children: [
                    // Closed Laptop Outline (Left side of desk)
                    Positioned(
                      left: 12,
                      top: 24,
                      child: Container(
                        width: 120,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppLayout.radius6),
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F4EE),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Open Textbook (Right side of desk)
                    Positioned(
                      right: 12,
                      top: 18,
                      child: Container(
                        width: 140,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppLayout.radius6),
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: Row(
                          children: [
                            // Left page
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  border: Border(right: BorderSide(color: AppColors.border, width: 1)),
                                ),
                                 child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PageLine(widthFraction: 0.75),
                                    _PageLine(widthFraction: 0.9),
                                    _PageLine(widthFraction: 0.85),
                                    _PageLine(widthFraction: 0.6),
                                  ],
                                ),
                              ),
                            ),
                            // Right page
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PageLine(widthFraction: 0.8),
                                    _PageLine(widthFraction: 0.85),
                                    _PageLine(widthFraction: 0.7),
                                    _PageLine(widthFraction: 0.5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Terracotta Question Mark (Floats above the open textbook)
          Positioned(
            right: 56,
            bottom: 95,
            child: AnimatedBuilder(
              animation: floatController,
              builder: (ctx, child) {
                final offsetY = -6.0 * math.sin(floatController.value * math.pi);
                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: child,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '?',
                  style: TextStyle(
                    fontFamily: 'Newsreader',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageLine extends StatelessWidget {
  final double widthFraction;
  const _PageLine({required this.widthFraction});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFraction,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flat Clock Painter: shows exact hour and minute with 1px lines
// ---------------------------------------------------------------------------
class _ClockPainter extends CustomPainter {
  final int hours;
  final int minutes;

  _ClockPainter({required this.hours, required this.minutes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintLine = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Center pivot
    final pivotPaint = Paint()..color = AppColors.ink;
    canvas.drawCircle(center, 1.8, pivotPaint);

    // Minute hand (points to minutes / 60 * 2pi - pi/2)
    final minAngle = (minutes / 60.0) * 2 * math.pi - (math.pi / 2);
    final minHandLength = radius * 0.65;
    final minTarget = center + Offset(minHandLength * math.cos(minAngle), minHandLength * math.sin(minAngle));
    canvas.drawLine(center, minTarget, paintLine);

    // Hour hand (points to (hours % 12 + minutes/60) / 12 * 2pi - pi/2)
    final hourAngle = ((hours % 12 + minutes / 60.0) / 12.0) * 2 * math.pi - (math.pi / 2);
    final hourHandLength = radius * 0.45;
    final hourTarget = center + Offset(hourHandLength * math.cos(hourAngle), hourHandLength * math.sin(hourAngle));
    paintLine.strokeWidth = 1.6;
    canvas.drawLine(center, hourTarget, paintLine);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.hours != hours || oldDelegate.minutes != minutes;
  }
}
