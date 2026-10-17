import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

/// Scene 3: Still stuck.
/// The video cards fall away into distance. The screen empties.
/// Only the question mark remains, larger in the center.
class Scene3Stuck extends StatelessWidget {
  final double overallProgress;

  const Scene3Stuck({
    super.key,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(3, overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(3, overallProgress);

    // Fade in at start, stay solid, fade out at end
    double opacity = 1.0;
    if (p < 0.20) {
      opacity = (p / 0.20).clamp(0.0, 1.0);
    } else if (p > 0.80) {
      opacity = (1.0 - (p - 0.80) / 0.20).clamp(0.0, 1.0);
    }

    // Question mark scales up as visitor scrolls
    final qScale = SceneProgress.lerp(1.1, 1.7, SceneProgress.easeInOut(p.clamp(0.0, 1.0)));
    final zShift = SceneProgress.lerp(30.0, -10.0, p.clamp(0.0, 1.0));

    // Cards falling away into the distance in early part of scene (p: 0.0 to 0.4)
    final fallProgress = (p / 0.45).clamp(0.0, 1.0);
    final cardFallZ = SceneProgress.lerp(-40.0, -220.0, fallProgress);
    final cardFallOpacity = (1.0 - fallProgress).clamp(0.0, 1.0);
    final cardFallY = SceneProgress.lerp(0.0, 140.0, fallProgress);

    return RepaintBoundary(
      child: Depth3D(
        z: zShift,
        opacity: opacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fading falling card ghosts (simulating search results falling away)
                  if (fallProgress < 1.0)
                    Transform.translate(
                      offset: Offset(0, cardFallY),
                      child: Depth3D(
                        z: cardFallZ,
                        rotateX: 0.25 * fallProgress,
                        opacity: cardFallOpacity * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppLayout.radius6),
                                border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 8,
                                  color: AppColors.muted.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppLayout.space20),
                            Container(
                              width: 220,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppLayout.radius6),
                                border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                              ),
                              child: Center(
                                child: Container(
                                  width: 90,
                                  height: 8,
                                  color: AppColors.muted.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Central Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large Terracotta Question Mark
                      Transform.scale(
                        scale: qScale,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '?',
                            semanticsLabel: 'Unanswered doubt question mark',
                            style: tt.displayLarge?.copyWith(
                              color: AppColors.accent,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppLayout.space32),

                      // Scene 3 Copy
                      Text(
                        'You still have the doubt, and the test is close.',
                        textAlign: TextAlign.center,
                        style: tt.displayMedium?.copyWith(
                          color: AppColors.ink,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppLayout.space12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          'Generic online video tutorials do not know your college syllabus or your professor\'s exact exam style.',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
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
