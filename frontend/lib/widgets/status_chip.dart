import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/session_request.dart';

// Status chip for session request state.
// Pills shape (StadiumBorder), muted earth-tone status colors, outlined icon.
// No rainbow: only the 4 status tokens from AppColors.
class StatusChip extends StatelessWidget {
  final RequestStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: cfg.fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 12, color: cfg.fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cfg.fg, fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  static _ChipConfig _config(RequestStatus s) {
    switch (s) {
      case RequestStatus.pending:
        return const _ChipConfig(
          fg: AppColors.pending, bg: AppColors.pendingBg,
          icon: Icons.schedule_outlined,
        );
      case RequestStatus.accepted:
        return const _ChipConfig(
          fg: AppColors.accepted, bg: AppColors.acceptedBg,
          icon: Icons.check_circle_outline,
        );
      case RequestStatus.declined:
        return const _ChipConfig(
          fg: AppColors.declined, bg: AppColors.declinedBg,
          icon: Icons.cancel_outlined,
        );
      case RequestStatus.cancelled:
        return const _ChipConfig(
          fg: AppColors.cancelled, bg: AppColors.cancelledBg,
          icon: Icons.remove_circle_outline,
        );
    }
  }
}

class _ChipConfig {
  final Color    fg;
  final Color    bg;
  final IconData icon;
  const _ChipConfig({required this.fg, required this.bg, required this.icon});
}
