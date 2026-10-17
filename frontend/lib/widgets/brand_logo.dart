import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

// ---------------------------------------------------------------------------
// StudyCircle Brand Logo
// Displays the official StudyCircle emblem and branding.
// ---------------------------------------------------------------------------

class StudyCircleLogo extends StatelessWidget {
  final double height;
  final bool showText;
  final VoidCallback? onTap;

  const StudyCircleLogo({
    super.key,
    this.height = 36.0,
    this.showText = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget emblem = ClipRRect(
      borderRadius: BorderRadius.circular(AppLayout.radius6),
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        width: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: height,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppLayout.radius6),
          ),
          alignment: Alignment.center,
          child: Text(
            'SC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: height * 0.4,
            ),
          ),
        ),
      ),
    );

    Widget content;
    if (!showText) {
      content = emblem;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          emblem,
          const SizedBox(width: AppLayout.space10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kAppName,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.ink,
                  height: 1.1,
                ),
              ),
              Text(
                kAppTagline,
                style: tt.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radius6),
        child: content,
      );
    }

    return content;
  }
}
