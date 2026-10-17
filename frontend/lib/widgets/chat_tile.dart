import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/chat.dart';
import 'initials_avatar.dart';
import 'chat_status_chip.dart';

// ---------------------------------------------------------------------------
// ChatTile — Screen 8 specification item
// (avatar, other person's name, subject, last message preview, time, status chip)
// ---------------------------------------------------------------------------
class ChatTile extends StatelessWidget {
  final ChatListItem item;

  const ChatTile({super.key, required this.item});

  String get _initials {
    final parts = item.otherUser.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  String get _timeString {
    if (item.lastMessage == null) return '';
    final dt = item.lastMessage!.sentAt;
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    return isToday ? AppFormatters.time(dt) : AppFormatters.date(dt);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: AppTheme.borderRadius,
        child: InkWell(
          borderRadius: AppTheme.borderRadius,
          onTap: () => context.go('/chats/${item.requestId}'),
          child: Padding(
            padding: const EdgeInsets.all(AppLayout.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                InitialsAvatar(
                  initials: _initials,
                  size: 44,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.onPrimary,
                ),
                const SizedBox(width: AppLayout.space12),

                // Center content (Name, Subject, Last message)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.otherUser.name,
                              style: tt.headlineSmall?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_timeString.isNotEmpty) ...[
                            const SizedBox(width: AppLayout.space8),
                            Text(
                              _timeString,
                              style: tt.labelSmall?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Subject badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          item.subject.name,
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Last message preview or placeholder
                      Text(
                        item.lastMessage?.content ?? 'No messages yet',
                        style: tt.bodySmall?.copyWith(
                          color: item.lastMessage != null ? AppColors.ink : AppColors.muted,
                          fontStyle: item.lastMessage != null ? FontStyle.normal : FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppLayout.space12),

                // Right column: Status chip
                ChatStatusChip(chat: item.chat),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
