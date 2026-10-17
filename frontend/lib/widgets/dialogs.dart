import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// Confirm dialog helper.
// Returns true if the user confirmed, false if cancelled.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel  = 'Cancel',
  bool   destructive  = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.declined)
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Snackbar helpers — success and error variants.
// Shown as floating snackbars per theme (dark bg, no shadow).
void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.white),
            const SizedBox(width: AppLayout.space8),
            Expanded(child: Text(message)),
          ]),
          backgroundColor: AppColors.accepted,
          behavior:        SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
          elevation: 0,
        ),
      );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, size: 16, color: AppColors.white),
            const SizedBox(width: AppLayout.space8),
            Expanded(child: Text(message)),
          ]),
          backgroundColor: AppColors.declined,
          behavior:        SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
          elevation: 0,
        ),
      );
}
