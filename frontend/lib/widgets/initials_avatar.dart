import 'package:flutter/material.dart';
import '../core/theme.dart';

// InitialsAvatar — circle with 1-2 letter initials, 1px border, no shadow.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color  backgroundColor;
  final Color  textColor;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size            = 36,
    this.backgroundColor = AppColors.primary,
    this.textColor       = AppColors.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.38;
    return Semantics(
      label: 'Avatar with initials $initials',
      child: Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(
          color:        backgroundColor,
          shape:        BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          initials.length > 2 ? initials.substring(0, 2) : initials,
          style: TextStyle(
            fontSize:   fontSize,
            fontWeight: FontWeight.w600,
            color:      textColor,
            height:     1,
          ),
        ),
      ),
    );
  }
}
