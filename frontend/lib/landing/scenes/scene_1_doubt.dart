import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

class Scene1Doubt extends StatelessWidget {
  final double overallProgress;

  const Scene1Doubt({
    super.key,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(1, overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(1, overallProgress);

    // Fade in p 0.0 -> 0.25, solid 0.25 -> 0.75, fade out 0.75 -> 1.0
    double opacity = 1.0;
    if (p < 0.25) {
      opacity = (p / 0.25).clamp(0.0, 1.0);
    } else if (p > 0.75) {
      opacity = (1.0 - (p - 0.75) / 0.25).clamp(0.0, 1.0);
    }

    // Camera moves in on the textbook (scale up and shift slightly)
    final scale = SceneProgress.lerp(0.95, 1.12, p.clamp(0.0, 1.0));
    final zShift = SceneProgress.lerp(60.0, -10.0, p.clamp(0.0, 1.0));

    return RepaintBoundary(
      child: Depth3D(
        z: zShift,
        scale: scale,
        opacity: opacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status: 11:40 PM Wall Clock + Section Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppLayout.radius6),
                          border: Border.all(color: AppColors.accent, width: AppLayout.borderWidth1),
                        ),
                        child: Text(
                          '11:40 PM',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Small Wall Clock
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: CustomPaint(
                          painter: _ClockScene1Painter(hours: 11, minutes: 40),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.space16),

                  // Headline Copy
                  Text(
                    '11:40 PM. Chapter 4, question 7. Nothing in your textbook explains it.',
                    style: tt.displayMedium?.copyWith(
                      color: AppColors.ink,
                      height: 1.25,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: AppLayout.space20),

                  // Zoomed-in Textbook Open Spread
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppLayout.radius6),
                      border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                    ),
                    padding: const EdgeInsets.all(AppLayout.space24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Textbook Chapter Title Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CHAPTER 4: GRAPH TRAVERSALS',
                              style: tt.labelSmall?.copyWith(
                                color: AppColors.muted,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'PAGE 142',
                              style: tt.labelSmall?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppLayout.space16),
                        const Divider(height: 1),
                        const SizedBox(height: AppLayout.space16),

                        // Textbook Question 6 (regular text)
                        Text(
                          '6. Contrast adjacency lists with adjacency matrices for sparse graph representations.',
                          style: tt.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: AppLayout.space16),

                        // Question 7 (Circled in terracotta)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF4F0), // Subtle warm tint
                            borderRadius: BorderRadius.circular(AppLayout.radius6),
                            border: Border.all(color: AppColors.accent, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'QUESTION 7',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Circled in terracotta',
                                    style: tt.labelSmall?.copyWith(color: AppColors.accent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Explain why Breadth-First Search (BFS) strictly fails to find shortest paths if implemented with a LIFO stack instead of a FIFO queue.',
                                style: tt.bodyMedium?.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Textbook note: "Proof left as an exercise for the student."',
                                style: tt.labelSmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
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
    );
  }
}

class _ClockScene1Painter extends CustomPainter {
  final int hours;
  final int minutes;

  _ClockScene1Painter({required this.hours, required this.minutes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintLine = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, 1.8, Paint()..color = AppColors.ink);

    final minAngle = (minutes / 60.0) * 2 * math.pi - (math.pi / 2);
    final minHandLength = radius * 0.65;
    canvas.drawLine(center, center + Offset(minHandLength * math.cos(minAngle), minHandLength * math.sin(minAngle)), paintLine);

    final hourAngle = ((hours % 12 + minutes / 60.0) / 12.0) * 2 * math.pi - (math.pi / 2);
    final hourHandLength = radius * 0.45;
    paintLine.strokeWidth = 1.6;
    canvas.drawLine(center, center + Offset(hourHandLength * math.cos(hourAngle), hourHandLength * math.sin(hourAngle)), paintLine);
  }

  @override
  bool shouldRepaint(covariant _ClockScene1Painter oldDelegate) {
    return oldDelegate.hours != hours || oldDelegate.minutes != minutes;
  }
}
