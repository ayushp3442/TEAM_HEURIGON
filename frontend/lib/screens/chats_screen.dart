import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/api_client.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../widgets/chat_tile.dart';
import '../widgets/skeleton.dart';

// ---------------------------------------------------------------------------
// ChatsScreen — Screen 8 (List of chats at /chats)
// ---------------------------------------------------------------------------
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late Future<List<ChatListItem>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = context.read<ChatService>().list();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.space16,
                  AppLayout.space24,
                  AppLayout.space16,
                  AppLayout.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chats', style: tt.displaySmall),
                    const SizedBox(height: AppLayout.space4),
                    Text(
                      'Post-session message history with your tutors and students.',
                      style: tt.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content with Pull to refresh
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async => _load(),
                  child: FutureBuilder<List<ChatListItem>>(
                    future: _future,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const _SkeletonChatList();
                      }

                      if (snap.hasError) {
                        return _ErrorState(
                          message: ApiClient.errorMessage(snap.error!),
                          onRetry: _load,
                        );
                      }

                      final chats = snap.data ?? [];

                      if (chats.isEmpty) {
                        return const _EmptyChatsState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppLayout.space16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: chats.length,
                        itemBuilder: (ctx, i) => ChatTile(item: chats[i]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// "No chats yet. A chat opens after an accepted session ends."
// ---------------------------------------------------------------------------
class _EmptyChatsState extends StatelessWidget {
  const _EmptyChatsState();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppLayout.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 26,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: AppLayout.space16),
            Text(
              'No chats yet.',
              style: tt.headlineMedium?.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppLayout.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                'A chat opens after an accepted session ends.',
                style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error State
// ---------------------------------------------------------------------------
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 40, color: AppColors.declined),
            const SizedBox(height: AppLayout.space12),
            Text('Could not load chats', style: tt.headlineSmall),
            const SizedBox(height: AppLayout.space4),
            Text(
              message,
              style: tt.bodySmall?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppLayout.space16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton List
// ---------------------------------------------------------------------------
class _SkeletonChatList extends StatelessWidget {
  const _SkeletonChatList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppLayout.space16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: AppLayout.space12),
        padding: const EdgeInsets.all(AppLayout.space16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppTheme.borderRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            SkeletonBox(width: 44, height: 44, radius: 22),
            SizedBox(width: AppLayout.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 16),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 12),
                  SizedBox(height: 6),
                  SkeletonBox(width: 200, height: 14),
                ],
              ),
            ),
            SizedBox(width: AppLayout.space12),
            SkeletonBox(width: 80, height: 24, radius: 100),
          ],
        ),
      ),
    );
  }
}
