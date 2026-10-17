import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

/// Scene 6: Chat for 24 hours.
/// Four message bubbles arranged in depth, rising into place one by one.
/// A ticking countdown from "24h 00m left" down to "23h 59m left" in accent terracotta.
/// Labeled "Example conversation".
class Scene6Chat extends StatelessWidget {
  final double overallProgress;

  const Scene6Chat({
    super.key,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(6, overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(6, overallProgress);

    // Global fade
    double sceneOpacity = 1.0;
    if (p < 0.15) {
      sceneOpacity = (p / 0.15).clamp(0.0, 1.0);
    } else if (p > 0.85) {
      sceneOpacity = (1.0 - (p - 0.85) / 0.15).clamp(0.0, 1.0);
    }

    // Countdown timer string ticking from "24h 00m left" down to "23h 59m left"
    final countdownString = (p > 0.45) ? '23h 59m left' : '24h 00m left';

    // 4 Bubbles rising in depth one by one
    // Bubble 1: student
    final pB1 = ((p - 0.05) / 0.25).clamp(0.0, 1.0);
    final zB1 = SceneProgress.lerp(-40.0, 0.0, SceneProgress.easeInOut(pB1));
    final yB1 = SceneProgress.lerp(25.0, 0.0, SceneProgress.easeInOut(pB1));
    final opB1 = (pB1 / 0.4).clamp(0.0, 1.0);

    // Bubble 2: senior tutor
    final pB2 = ((p - 0.22) / 0.25).clamp(0.0, 1.0);
    final zB2 = SceneProgress.lerp(-40.0, 0.0, SceneProgress.easeInOut(pB2));
    final yB2 = SceneProgress.lerp(25.0, 0.0, SceneProgress.easeInOut(pB2));
    final opB2 = (pB2 / 0.4).clamp(0.0, 1.0);

    // Bubble 3: student follow-up
    final pB3 = ((p - 0.40) / 0.25).clamp(0.0, 1.0);
    final zB3 = SceneProgress.lerp(-40.0, 0.0, SceneProgress.easeInOut(pB3));
    final yB3 = SceneProgress.lerp(25.0, 0.0, SceneProgress.easeInOut(pB3));
    final opB3 = (pB3 / 0.4).clamp(0.0, 1.0);

    // Bubble 4: senior tutor answer
    final pB4 = ((p - 0.58) / 0.25).clamp(0.0, 1.0);
    final zB4 = SceneProgress.lerp(-40.0, 0.0, SceneProgress.easeInOut(pB4));
    final yB4 = SceneProgress.lerp(25.0, 0.0, SceneProgress.easeInOut(pB4));
    final opB4 = (pB4 / 0.4).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Depth3D(
        z: 0,
        opacity: sceneOpacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with countdown and "Example conversation" label
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 13, color: AppColors.accent),
                            const SizedBox(width: 5),
                            Text(
                              countdownString,
                              style: tt.labelSmall?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: Text(
                          'Example conversation',
                          style: tt.labelSmall?.copyWith(color: AppColors.muted, fontSize: 10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppLayout.space16),

                  // Headline Copy
                  Text(
                    'After the session, the chat stays open for 24 hours. Ask the follow-up questions you only think of later.',
                    style: tt.displayMedium?.copyWith(
                      color: AppColors.ink,
                      height: 1.3,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: AppLayout.space24),

                  // Chat Frame with 4 message bubbles
                  Container(
                    padding: const EdgeInsets.all(AppLayout.space20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppLayout.radius6),
                      border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Message 1 (Student - own bubble in primary green)
                        if (opB1 > 0.01)
                          Depth3D(
                            z: zB1,
                            y: yB1,
                            opacity: opB1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 420),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                                ),
                                child: Text(
                                  'Why does BFS use a queue instead of a stack?',
                                  style: tt.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: AppLayout.space12),

                        // Message 2 (Senior Tutor - surface color with 1px border)
                        if (opB2 > 0.01)
                          Depth3D(
                            z: zB2,
                            y: yB2,
                            opacity: opB2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 460),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: AppLayout.borderWidth1,
                                  ),
                                ),
                                child: Text(
                                  'BFS explores level by level. A FIFO queue guarantees you finish level k before touching level k+1.',
                                  style: tt.bodySmall?.copyWith(
                                    color: AppColors.ink,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: AppLayout.space12),

                        // Message 3 (Student follow-up - primary green)
                        if (opB3 > 0.01)
                          Depth3D(
                            z: zB3,
                            y: yB3,
                            opacity: opB3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 420),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                                ),
                                child: Text(
                                  'And DFS uses a stack because it goes deep along one branch first?',
                                  style: tt.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: AppLayout.space12),

                        // Message 4 (Senior Tutor answer - surface with 1px border)
                        if (opB4 > 0.01)
                          Depth3D(
                            z: zB4,
                            y: yB4,
                            opacity: opB4,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 460),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: AppLayout.borderWidth1,
                                  ),
                                ),
                                child: Text(
                                  'Exactly. LIFO lets DFS backtrack to the most recent unvisited neighbor.',
                                  style: tt.bodySmall?.copyWith(
                                    color: AppColors.ink,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
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
    );
  }
}
