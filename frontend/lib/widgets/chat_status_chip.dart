import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/session_request.dart';

// ---------------------------------------------------------------------------
// ChatStatusChip
// Displays:
// - OPEN: "Open, 18h left" (or remaining), turns accent color when < 1 hour left
// - NOT_STARTED: "Opens after session"
// - CLOSED: "Closed"
// ---------------------------------------------------------------------------
class ChatStatusChip extends StatelessWidget {
  final ChatInfo chat;

  const ChatStatusChip({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final cfg = _resolveConfig(chat);

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
            cfg.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cfg.fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  static _ChatChipConfig _resolveConfig(ChatInfo chat) {
    switch (chat.state) {
      case ChatState.open:
        final diff = chat.closesAt.difference(DateTime.now());
        if (diff.isNegative) {
          return const _ChatChipConfig(
            label: 'Closed',
            fg: AppColors.muted,
            bg: AppColors.cancelledBg,
            icon: Icons.lock_outline,
          );
        }
        final isUrgent = diff < const Duration(hours: 1);
        final remainingStr = AppFormatters.remaining(chat.closesAt);
        return _ChatChipConfig(
          label: 'Open, $remainingStr',
          fg: isUrgent ? AppColors.accent : AppColors.accepted,
          bg: isUrgent ? AppColors.accent.withValues(alpha: 0.12) : AppColors.acceptedBg,
          icon: isUrgent ? Icons.timer_outlined : Icons.chat_bubble_outline,
        );

      case ChatState.notStarted:
        return const _ChatChipConfig(
          label: 'Opens after session',
          fg: AppColors.pending,
          bg: AppColors.pendingBg,
          icon: Icons.schedule_outlined,
        );

      case ChatState.closed:
        return const _ChatChipConfig(
          label: 'Closed',
          fg: AppColors.muted,
          bg: AppColors.cancelledBg,
          icon: Icons.lock_outline,
        );
    }
  }
}

class _ChatChipConfig {
  final String   label;
  final Color    fg;
  final Color    bg;
  final IconData icon;

  const _ChatChipConfig({
    required this.label,
    required this.fg,
    required this.bg,
    required this.icon,
  });
}
