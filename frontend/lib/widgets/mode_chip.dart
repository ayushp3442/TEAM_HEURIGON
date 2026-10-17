import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/slot.dart';

// ModeChip — ONLINE or ON_CAMPUS.
// Pill shape, uses border only (no filled color to avoid rainbow risk).
class ModeChip extends StatelessWidget {
  final SlotMode mode;
  const ModeChip({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isOnline = mode == SlotMode.online;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.videocam_outlined : Icons.location_on_outlined,
            size: 12,
            color: AppColors.muted,
          ),
          const SizedBox(width: 4),
          Text(
            mode.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ],
      ),
    );
  }
}

// String overload for when mode comes as a raw string
class ModeChipStr extends StatelessWidget {
  final String mode; // "ONLINE" | "ON_CAMPUS"
  const ModeChipStr({super.key, required this.mode});

  @override
  Widget build(BuildContext context) =>
      ModeChip(mode: SlotMode.fromString(mode));
}
