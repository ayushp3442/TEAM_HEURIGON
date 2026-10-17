import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/brand_logo.dart';
import '../depth_3d.dart';
import '../scroll_engine.dart';

/// Scene 7: Your turn.
/// Camera returns to the desk plane.
/// The textbook is now closed, the question mark is gone.
/// Dual CTAs with preselected roles, second line for seniors, and honest footer.
class Scene7Cta extends StatefulWidget {
  final double overallProgress;

  const Scene7Cta({
    super.key,
    required this.overallProgress,
  });

  @override
  State<Scene7Cta> createState() => _Scene7CtaState();
}

class _Scene7CtaState extends State<Scene7Cta> {
  static bool _warnedMissingEmail = false;

  @override
  void initState() {
    super.initState();
    if (kContactEmail.isEmpty && !_warnedMissingEmail) {
      _warnedMissingEmail = true;
      debugPrint(
        'Notice: CONTACT_EMAIL not configured via --dart-define; hiding contact email in footer.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SceneProgress.isVisible(7, widget.overallProgress)) {
      return const SizedBox.shrink();
    }

    final tt = Theme.of(context).textTheme;
    final p = SceneProgress.raw(7, widget.overallProgress);

    // Fades in p 0.0 -> 0.35, then stays solid
    final opacity = (p / 0.35).clamp(0.0, 1.0);
    final zShift = SceneProgress.lerp(50.0, 0.0, p.clamp(0.0, 1.0));

    return RepaintBoundary(
      child: Depth3D(
        z: zShift,
        opacity: opacity,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.space24,
                  vertical: AppLayout.space32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo
                    const StudyCircleLogo(
                      height: 44,
                      showText: true,
                    ),
                    const SizedBox(height: AppLayout.space24),

                    // Returned Desk Illustration (Closed book, question mark gone)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppLayout.space16),
                        child: Depth3D(
                          rotateX: 0.25, // Tilted desk plane
                          child: Container(
                            width: 320,
                            padding: const EdgeInsets.all(AppLayout.space16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppLayout.radius6),
                              border: Border.all(
                                color: AppColors.border,
                                width: AppLayout.borderWidth1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Closed textbook
                                Container(
                                  width: 72,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: AppLayout.borderWidth1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        color: AppColors.primary,
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            width: 32,
                                            height: 4,
                                            color: AppColors.muted.withValues(alpha: 0.3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppLayout.space24),
                                // Closed laptop
                                Container(
                                  width: 90,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: AppLayout.borderWidth1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.muted.withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppLayout.space20),

                    // Final Copy
                    Text(
                      'Next time you get stuck, ask a senior.',
                      style: tt.displayLarge?.copyWith(
                        fontSize: 32,
                        color: AppColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppLayout.space12),
                    Text(
                      'Know this subject well? Post your free slots and help the juniors.',
                      style: tt.bodyLarge?.copyWith(
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppLayout.space28),

                    // Action Buttons (Same routes and role preselection as Hero)
                    Wrap(
                      spacing: AppLayout.space12,
                      runSpacing: AppLayout.space12,
                      children: [
                        FilledButton(
                          onPressed: () => context.go('/register?role=student'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                            side: const BorderSide(
                              color: AppColors.border,
                              width: AppLayout.borderWidth1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppLayout.radius6),
                            ),
                          ),
                          child: const Text('Become a tutor'),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppLayout.space40),
                    const Divider(height: 1),
                    const SizedBox(height: AppLayout.space20),

                    // Plain responsive footer
                    Wrap(
                      spacing: AppLayout.space16,
                      runSpacing: AppLayout.space10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          '$kAppName © 2026',
                          style: tt.labelSmall?.copyWith(color: AppColors.muted),
                        ),
                        InkWell(
                          onTap: () => context.go('/privacy'),
                          child: Text('Privacy Policy', style: tt.labelSmall),
                        ),
                        InkWell(
                          onTap: () => context.go('/terms'),
                          child: Text('Terms of Service', style: tt.labelSmall),
                        ),
                        if (kContactEmail.isNotEmpty)
                          Text(
                            kContactEmail,
                            style: tt.labelSmall?.copyWith(color: AppColors.muted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
