import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/tutor.dart';
import 'initials_avatar.dart';
import 'mode_chip.dart';

// TutorCard — dense and informational, not a marketing card.
// avatar · name · dept/year · 2-line bio · subject chips · next slot · open count
class TutorCard extends StatelessWidget {
  final TutorSummary tutor;
  const TutorCard({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final initials = _initials(tutor.name);

    return InkWell(
      onTap: () => context.go('/tutors/${tutor.id}'),
      borderRadius: AppTheme.borderRadius,
      hoverColor: AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppLayout.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + dept/year
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InitialsAvatar(initials: initials, size: 38),
                const SizedBox(width: AppLayout.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor.name,
                        style: tt.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tutor.department} · Year ${tutor.yearOfStudy}',
                        style: tt.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.space12),

            // Bio — max 2 lines
            if (tutor.bio.isNotEmpty)
              Text(
                tutor.bio,
                style: tt.bodySmall?.copyWith(color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: AppLayout.space12),

            // Subject chips
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: tutor.subjects.take(3).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(s.name, style: tt.labelSmall),
                );
              }).toList(),
            ),
            const SizedBox(height: AppLayout.space12),

            // Divider
            const Divider(height: 1),
            const SizedBox(height: AppLayout.space12),

            // Next slot + slot count row
            Row(
              children: [
                // Next slot
                if (tutor.nextSlot != null) ...[
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppFormatters.dateTime(tutor.nextSlot!.startTime),
                      style: tt.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ModeChipStr(mode: tutor.nextSlot!.mode),
                ] else
                  Expanded(
                    child: Text(
                      'No upcoming slots',
                      style: tt.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppLayout.space4),
            Text(
              '${tutor.openSlotCount} open ${tutor.openSlotCount == 1 ? 'slot' : 'slots'}',
              style: tt.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppLayout.space12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/tutors/${tutor.id}'),
                child: const Text('View and request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}
