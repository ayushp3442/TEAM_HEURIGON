import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

/// Scene 5: How it works.
/// The camera travels forward along a 3D path.
/// Three numbered step panels are placed at increasing depth (z).
/// As visitor scrolls, the camera passes each panel, which scales up as it
/// approaches and moves aside as it passes.
class Scene5Workflow extends StatelessWidget {
  final double overallProgress;

  const Scene5Workflow({
    super.key,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(5, overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(5, overallProgress);

    // Global scene opacity
    double sceneOpacity = 1.0;
    if (p < 0.15) {
      sceneOpacity = (p / 0.15).clamp(0.0, 1.0);
    } else if (p > 0.85) {
      sceneOpacity = (1.0 - (p - 0.85) / 0.15).clamp(0.0, 1.0);
    }

    // Step 1: active 0.0 -> 0.35
    final p1 = (p / 0.35).clamp(0.0, 1.0);
    final z1 = SceneProgress.lerp(0.0, 60.0, p1);
    final scale1 = SceneProgress.lerp(1.0, 1.08, p1);
    final x1 = SceneProgress.lerp(0.0, -90.0, p1 * p1);
    final opacity1 = (1.0 - (p1 - 0.70) / 0.30).clamp(0.0, 1.0);

    // Step 2: active 0.30 -> 0.70
    final p2 = ((p - 0.30) / 0.40).clamp(0.0, 1.0);
    final z2 = SceneProgress.lerp(-90.0, 40.0, p2);
    final scale2 = SceneProgress.lerp(0.92, 1.06, p2);
    final x2 = SceneProgress.lerp(60.0, 0.0, (p2 * 2).clamp(0.0, 1.0)) +
        SceneProgress.lerp(0.0, 90.0, ((p2 - 0.7) / 0.3).clamp(0.0, 1.0));
    double opacity2 = 1.0;
    if (p < 0.30) {
      opacity2 = ((p - 0.15) / 0.15).clamp(0.0, 0.6);
    } else if (p2 > 0.75) {
      opacity2 = (1.0 - (p2 - 0.75) / 0.25).clamp(0.0, 1.0);
    }

    // Step 3: active 0.65 -> 1.0
    final p3 = ((p - 0.60) / 0.40).clamp(0.0, 1.0);
    final z3 = SceneProgress.lerp(-120.0, 0.0, SceneProgress.easeInOut(p3));
    final scale3 = SceneProgress.lerp(0.90, 1.0, SceneProgress.easeInOut(p3));
    final x3 = SceneProgress.lerp(-40.0, 0.0, p3);
    final opacity3 = (p3 / 0.35).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Depth3D(
        z: 0,
        opacity: sceneOpacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'How it works',
                    style: tt.displayMedium?.copyWith(
                      color: AppColors.ink,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppLayout.space8),
                  Text(
                    'Three steps to connect with a senior from your college.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppLayout.space28),

                  // 3D Path of Panels
                  SizedBox(
                    height: 290,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Step 3 (furthest along path, approaches last)
                        if (opacity3 > 0.02)
                          Depth3D(
                            z: z3,
                            x: x3,
                            scale: scale3,
                            opacity: opacity3,
                            child: const _StepPanel(
                              stepNum: '3',
                              title: 'Meet online or on campus',
                              subtitle:
                                  'Attend your 1-on-1 session and get your concepts cleared step by step.',
                              badgeLabel: 'Step 3 of 3',
                            ),
                          ),

                        // Step 2 (middle step along path)
                        if (opacity2 > 0.02)
                          Depth3D(
                            z: z2,
                            x: x2,
                            scale: scale2,
                            opacity: opacity2,
                            child: const _StepPanel(
                              stepNum: '2',
                              title: 'Request a slot with a short message',
                              subtitle:
                                  'Tell the senior what specific doubt or assignment problem you need help with.',
                              badgeLabel: 'Step 2 of 3',
                            ),
                          ),

                        // Step 1 (first step in camera path)
                        if (opacity1 > 0.02)
                          Depth3D(
                            z: z1,
                            x: x1,
                            scale: scale1,
                            opacity: opacity1,
                            child: const _StepPanel(
                              stepNum: '1',
                              title: 'Search by subject, mode, and date',
                              subtitle:
                                  'Filter by your exact college course and choose online or on campus.',
                              badgeLabel: 'Step 1 of 3',
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

class _StepPanel extends StatelessWidget {
  final String stepNum;
  final String title;
  final String subtitle;
  final String badgeLabel;

  const _StepPanel({
    required this.stepNum,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 580),
      child: Container(
        padding: const EdgeInsets.all(AppLayout.space24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppLayout.radius6),
          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Number in Newsreader display font
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppLayout.radius6),
                border: Border.all(color: AppColors.primary, width: AppLayout.borderWidth1),
              ),
              alignment: Alignment.center,
              child: Text(
                stepNum,
                style: tt.displayMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: AppLayout.space20),

            // Step Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: Text(
                          badgeLabel,
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: tt.titleMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.muted,
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
