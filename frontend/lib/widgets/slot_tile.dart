import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/slot.dart';
import 'mode_chip.dart';

// SlotTile — used in TutorDetail (with optional Request button)
//            and TutorDashboard (with delete button).
class SlotTile extends StatelessWidget {
  final Slot          slot;
  final VoidCallback? onRequest;   // null = no request button (tutor view)
  final VoidCallback? onDelete;    // null = no delete button (student view)
  final bool          isBooked;

  const SlotTile({
    super.key,
    required this.slot,
    this.onRequest,
    this.onDelete,
    this.isBooked = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final booked = slot.booked || isBooked;

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.space8),
      decoration: BoxDecoration(
        color: booked ? AppColors.background : AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.space16, vertical: AppLayout.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date/time column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppFormatters.dateTime(slot.startTime),
                  style: tt.labelLarge?.copyWith(
                    color: booked ? AppColors.muted : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppFormatters.time(slot.startTime)} – ${AppFormatters.time(slot.endTime)}'
                  '  ·  ${AppFormatters.duration(slot.startTime, slot.endTime)}',
                  style: tt.bodySmall,
                ),
                const SizedBox(height: AppLayout.space4),
                Row(
                  children: [
                    ModeChip(mode: slot.mode),
                    if (slot.locationOrLink.isNotEmpty) ...[
                      const SizedBox(width: AppLayout.space8),
                      Expanded(
                        child: Text(
                          slot.locationOrLink,
                          style: tt.bodySmall?.copyWith(color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                // Pending request count (tutor view)
                if (!booked &&
                    slot.requestCount != null &&
                    slot.requestCount! > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${slot.requestCount} pending '
                    '${slot.requestCount == 1 ? 'request' : 'requests'}',
                    style: tt.bodySmall?.copyWith(color: AppColors.pending),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppLayout.space12),

          // Action button
          if (booked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('Booked', style: tt.labelSmall?.copyWith(color: AppColors.muted)),
            )
          else if (onRequest != null)
            FilledButton(
              onPressed: onRequest,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Request'),
            )
          else if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
              tooltip: 'Delete slot',
            ),
        ],
      ),
    );
  }
}
