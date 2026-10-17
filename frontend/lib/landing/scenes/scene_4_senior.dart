import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

/// Scene 4: A senior who has been there.
/// The question mark turns deep green and shrinks away as the tutor card
/// rises from depth on the z-axis toward the viewer with connected depth labels.
class Scene4Senior extends StatefulWidget {
  final double overallProgress;

  const Scene4Senior({
    super.key,
    required this.overallProgress,
  });

  @override
  State<Scene4Senior> createState() => _Scene4SeniorState();
}

class _Scene4SeniorState extends State<Scene4Senior> {
  static bool _warnedMissingAsset = false;
  bool _hasTutorCardAsset = false;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    try {
      await rootBundle.load('assets/landing/tutor-card.png');
      if (mounted) setState(() => _hasTutorCardAsset = true);
    } catch (_) {
      if (!_warnedMissingAsset) {
        _warnedMissingAsset = true;
        debugPrint(
          'Notice: assets/landing/tutor-card.png not found; rendering clean wireframe tutor card.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(4, widget.overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(4, widget.overallProgress);

    // Fade in at start, stay solid, fade out at end
    double opacity = 1.0;
    if (p < 0.20) {
      opacity = (p / 0.20).clamp(0.0, 1.0);
    } else if (p > 0.80) {
      opacity = (1.0 - (p - 0.80) / 0.20).clamp(0.0, 1.0);
    }

    // Question mark shrinks and turns green during p: 0.0 -> 0.35
    final qTransition = (p / 0.35).clamp(0.0, 1.0);
    final qColor = Color.lerp(AppColors.accent, AppColors.primary, qTransition)!;
    final qScale = SceneProgress.lerp(1.5, 0.4, SceneProgress.easeInOut(qTransition));
    final qOpacity = (1.0 - qTransition * 1.2).clamp(0.0, 1.0);

    // Tutor card rises from depth: z = -140 to 0, scale = 0.88 to 1.0
    final cardProgress = ((p - 0.15) / 0.70).clamp(0.0, 1.0);
    final easedCardProgress = SceneProgress.easeInOut(cardProgress);
    final cardZ = SceneProgress.lerp(-120.0, 0.0, easedCardProgress);
    final cardScale = SceneProgress.lerp(0.90, 1.0, easedCardProgress);
    final cardOpacity = (cardProgress / 0.3).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Depth3D(
        z: 0,
        opacity: opacity,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Transitioning question mark (turns green then shrinks away)
                  if (qOpacity > 0.01)
                    Transform.scale(
                      scale: qScale,
                      child: Opacity(
                        opacity: qOpacity,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: qColor, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '?',
                            style: tt.displayLarge?.copyWith(
                              color: qColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppLayout.space16),

                  // Scene 4 Headline
                  Text(
                    'A senior in your college has already solved this kind of problem. They are listed here with their subjects and free time slots.',
                    textAlign: TextAlign.center,
                    style: tt.displayMedium?.copyWith(
                      color: AppColors.ink,
                      height: 1.3,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: AppLayout.space28),

                  // Tutor Card with 3D Depth transform and Connected Pointer Lines
                  Depth3D(
                    z: cardZ,
                    scale: cardScale,
                    opacity: cardOpacity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card Body
                          Container(
                            padding: const EdgeInsets.all(AppLayout.space24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppLayout.radius6),
                              border: Border.all(
                                color: AppColors.primary,
                                width: AppLayout.borderWidth1,
                              ),
                            ),
                            child: _hasTutorCardAsset
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(AppLayout.radius6),
                                    child: Image.asset(
                                      'assets/landing/tutor-card.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : const _WireframeTutorCard(),
                          ),

                          // Three Connected Pointer Labels (Desktop / Tablet)
                          const Positioned(
                            top: -14,
                            left: 20,
                            child: _DepthLabel(
                              text: 'Subjects',
                              lineDirection: _LineDirection.down,
                            ),
                          ),
                          const Positioned(
                            bottom: -16,
                            left: 20,
                            child: _DepthLabel(
                              text: 'Free time slots',
                              lineDirection: _LineDirection.up,
                            ),
                          ),
                          const Positioned(
                            bottom: -16,
                            right: 20,
                            child: _DepthLabel(
                              text: 'Online or on campus',
                              lineDirection: _LineDirection.up,
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
      ),
    );
  }
}

/// Direction of the thin 1px connector line
enum _LineDirection { up, down }

/// Small depth tag with a 1px connector line
class _DepthLabel extends StatelessWidget {
  final String text;
  final _LineDirection lineDirection;

  const _DepthLabel({
    required this.text,
    required this.lineDirection,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppLayout.radius6),
        border: Border.all(color: AppColors.primary, width: AppLayout.borderWidth1),
      ),
      child: Text(
        text,
        style: tt.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );

    final line = Container(
      width: 1,
      height: 12,
      color: AppColors.primary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lineDirection == _LineDirection.up) ...[
          line,
          badge,
        ] else ...[
          badge,
          line,
        ],
      ],
    );
  }
}

/// Honest wireframe tutor card without invented personal identities or fake ratings.
class _WireframeTutorCard extends StatelessWidget {
  const _WireframeTutorCard();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: Generic academic avatar outline and subject tag
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.school_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppLayout.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.muted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppLayout.radius6),
                border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
              ),
              child: Text(
                'Senior Student',
                style: tt.labelSmall?.copyWith(color: AppColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppLayout.space20),
        const Divider(height: 1),
        const SizedBox(height: AppLayout.space16),

        // Subject chips section
        Text(
          'Subjects Offered',
          style: tt.labelSmall?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppLayout.space8),
        const Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _SubjectChip(title: 'Data Structures & Algorithms'),
            _SubjectChip(title: 'Discrete Mathematics'),
            _SubjectChip(title: 'Computer Systems'),
          ],
        ),

        const SizedBox(height: AppLayout.space16),

        // Available slots section
        Text(
          'Upcoming Available Slots',
          style: tt.labelSmall?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppLayout.space8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                  border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tomorrow, 4:00 PM - 5:00 PM',
                      style: tt.bodySmall?.copyWith(fontSize: 12, color: AppColors.ink),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                      ),
                      child: Text(
                        'Online',
                        style: tt.labelSmall?.copyWith(fontSize: 10, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String title;

  const _SubjectChip({required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppLayout.radius6),
        border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
      ),
      child: Text(
        title,
        style: tt.labelSmall?.copyWith(color: AppColors.ink, fontSize: 11),
      ),
    );
  }
}
