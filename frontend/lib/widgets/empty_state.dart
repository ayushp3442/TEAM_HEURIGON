import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// EmptyState — outlined icon, one clear sentence, optional action button.
// No marketing filler. No emojis.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   message;
  final String?  actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppLayout.space16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: AppTheme.borderRadius,
              ),
              child: Icon(icon, size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: AppLayout.space16),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppLayout.space16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ErrorView — shown when a network/server error occurs.
class ErrorView extends StatelessWidget {
  final String   message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 28, color: AppColors.muted),
            const SizedBox(height: AppLayout.space12),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppLayout.space16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined, size: 16),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
