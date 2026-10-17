import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

class Scene2Search extends StatelessWidget {
  final double overallProgress;

  const Scene2Search({
    super.key,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(2, overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(2, overallProgress);

    // Fade in p 0.0 -> 0.2, solid 0.2 -> 0.8, fade out 0.8 -> 1.0
    double opacity = 1.0;
    if (p < 0.2) {
      opacity = (p / 0.2).clamp(0.0, 1.0);
    } else if (p > 0.8) {
      opacity = (1.0 - (p - 0.8) / 0.2).clamp(0.0, 1.0);
    }

    final zShift = SceneProgress.lerp(40.0, -20.0, p.clamp(0.0, 1.0));

    final videoCards = [
      {'tag': 'Too advanced', 'dur': '45:12'},
      {'tag': 'Wrong syllabus', 'dur': '1:12:00'},
      {'tag': 'A different problem', 'dur': '32:05'},
      {'tag': '2 hours long', 'dur': '2:14:30'},
      {'tag': 'No reply to comments', 'dur': '18:40'},
    ];

    return RepaintBoundary(
      child: Depth3D(
        z: zShift,
        opacity: opacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline Copy
                  Text(
                    'So you search online. Hours of videos. Too long, wrong syllabus, a different problem, and nobody to reply to your comment.',
                    style: tt.displayMedium?.copyWith(
                      color: AppColors.ink,
                      height: 1.25,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppLayout.space20),

                  // Laptop Screen Frame
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppLayout.radius6),
                      border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                    ),
                    padding: const EdgeInsets.all(AppLayout.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Generic Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppLayout.radius6),
                            border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 16, color: AppColors.muted),
                              const SizedBox(width: 10),
                              Text(
                                'why does BFS use a queue in graph theory',
                                style: tt.bodySmall?.copyWith(color: AppColors.ink),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppLayout.space20),

                        // Stack of 5 Video Cards as 3D Planes
                        SizedBox(
                          height: 220,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: List.generate(videoCards.length, (i) {
                              final card = videoCards[i];
                              // Each card starts tilting and sliding back successively as p moves from 0.0 to 1.0
                              final cardProgress = ((p * 1.5) - (i * 0.18)).clamp(0.0, 1.0);
                              final cardZ = SceneProgress.lerp(0.0, -180.0, cardProgress);
                              final cardRotateY = SceneProgress.lerp(0.0, -0.22, cardProgress);
                              final cardRotateX = SceneProgress.lerp(0.0, 0.15, cardProgress);
                              final cardScale = SceneProgress.lerp(1.0, 0.75, cardProgress);

                              // Farther cards use a slightly lighter tone of background, not transparency
                              final isFar = cardProgress > 0.6;
                              final cardBg = isFar ? const Color(0xFFF6F3ED) : AppColors.surface;

                              return Positioned(
                                top: i * 36.0,
                                left: i * 16.0,
                                right: math.max(0.0, 80.0 - (i * 16.0)),
                                child: Depth3D(
                                  z: cardZ,
                                  rotateX: cardRotateX,
                                  rotateY: cardRotateY,
                                  scale: cardScale,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(AppLayout.radius6),
                                      border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                                    ),
                                    child: Row(
                                      children: [
                                        // Generic Video Thumbnail Block
                                        Container(
                                          width: 64,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                                          ),
                                          alignment: Alignment.center,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(Icons.play_arrow_outlined, size: 20, color: AppColors.muted),
                                              Positioned(
                                                bottom: 2,
                                                right: 3,
                                                child: Text(
                                                  card['dur']!,
                                                  style: const TextStyle(fontSize: 8, color: AppColors.muted),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppLayout.space12),

                                        // Title bar lines (generic placeholder bars)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 8,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: AppColors.ink,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                height: 6,
                                                width: 140,
                                                decoration: BoxDecoration(
                                                  color: AppColors.border,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: AppLayout.space12),

                                        // Tag from brief
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAF0EB),
                                            borderRadius: BorderRadius.circular(AppLayout.radius6),
                                            border: Border.all(color: AppColors.accent, width: AppLayout.borderWidth1),
                                          ),
                                          child: Text(
                                            card['tag']!,
                                            style: tt.labelSmall?.copyWith(
                                              color: AppColors.accent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
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
