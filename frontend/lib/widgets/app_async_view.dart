import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import 'empty_state.dart';

// AppAsyncView — wraps a Future<List<T>> and shows the right state.
// - Loading: skeleton builder (customisable per screen)
// - Error: ErrorView with retry
// - Empty: EmptyState with icon and message
// - Data: content builder
class AppAsyncView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget Function()? skeletonBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final bool Function(T)? isEmpty;

  const AppAsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.skeletonBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return skeletonBuilder?.call() ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppLayout.space32),
                  child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2,
                  ),
                ),
              );
        }
        if (snap.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(snap.error!, () {});
          }
          return ErrorView(message: snap.error.toString());
        }
        final data = snap.data as T;
        if (isEmpty != null && isEmpty!(data)) {
          return emptyBuilder?.call() ??
              const EmptyState(
                icon: Icons.inbox_outlined,
                message: 'Nothing here yet.',
              );
        }
        return builder(data);
      },
    );
  }
}
