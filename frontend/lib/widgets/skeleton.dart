import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// Skeleton loading widgets — flat muted blocks with slow opacity pulse.
// NO shimmer gradient. Rule: no gradients anywhere.

class SkeletonBox extends StatefulWidget {
  final double  width;
  final double  height;
  final double  radius;

  const SkeletonBox({
    super.key,
    this.width  = double.infinity,
    this.height = 14,
    this.radius = 4,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width:  widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color:        AppColors.border,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

// Skeleton for a TutorCard
class TutorCardSkeleton extends StatelessWidget {
  const TutorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SkeletonBox(width: 36, height: 36, radius: 18),
            SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 140),
                SizedBox(height: 6),
                SkeletonBox(height: 12, width: 100),
              ],
            )),
          ]),
          SizedBox(height: 12),
          SkeletonBox(height: 12),
          SizedBox(height: 6),
          SkeletonBox(height: 12, width: 220),
          SizedBox(height: 12),
          Row(children: [
            SkeletonBox(width: 60, height: 20, radius: 10),
            SizedBox(width: 8),
            SkeletonBox(width: 72, height: 20, radius: 10),
          ]),
        ],
      ),
    );
  }
}

// Skeleton for a SlotTile
class SlotTileSkeleton extends StatelessWidget {
  const SlotTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.space16),
      margin: const EdgeInsets.only(bottom: AppLayout.space8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 14, width: 180),
            SizedBox(height: 6),
            SkeletonBox(height: 12, width: 120),
          ],
        )),
        SkeletonBox(width: 60, height: 28, radius: 6),
      ]),
    );
  }
}

// Skeleton for a RequestCard
class RequestCardSkeleton extends StatelessWidget {
  const RequestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.space16),
      margin: const EdgeInsets.only(bottom: AppLayout.space8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: SkeletonBox(height: 14, width: 160)),
            SizedBox(width: 8),
            SkeletonBox(width: 72, height: 22, radius: 100),
          ]),
          SizedBox(height: 8),
          SkeletonBox(height: 12),
          SizedBox(height: 6),
          SkeletonBox(height: 12, width: 240),
          SizedBox(height: 12),
          SkeletonBox(height: 12, width: 140),
        ],
      ),
    );
  }
}
