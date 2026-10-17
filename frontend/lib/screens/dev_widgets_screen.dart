// DEVELOPMENT ONLY — removed in Stage F11.
// Route: /dev/widgets
// Shows every shared widget in every state at narrow and wide widths.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/session_request.dart';
import '../models/slot.dart';
import '../widgets/status_chip.dart';
import '../widgets/mode_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/dialogs.dart';
import '../widgets/app_async_view.dart';

class DevWidgetsScreen extends StatelessWidget {
  const DevWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Widget Showcase — DEV ONLY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => context.go('/browse'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.space16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(label: 'StatusChip', children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final s in RequestStatus.values) StatusChip(status: s),
                  ]),
                ]),

                const _Section(label: 'ModeChip', children: [
                  Wrap(spacing: 8, children: [
                    ModeChip(mode: SlotMode.online),
                    ModeChip(mode: SlotMode.onCampus),
                  ]),
                ]),

                const _Section(label: 'InitialsAvatar', children: [
                  Wrap(spacing: 12, children: [
                    InitialsAvatar(initials: 'AS', size: 32),
                    InitialsAvatar(initials: 'PV', size: 40),
                    InitialsAvatar(initials: 'RD', size: 48, backgroundColor: AppColors.muted),
                    InitialsAvatar(initials: 'KP', size: 56),
                  ]),
                ]),

                _Section(label: 'EmptyState', children: [
                  SizedBox(
                    height: 200,
                    child: EmptyState(
                      icon: Icons.search_off_outlined,
                      message: 'No tutors found for these filters.',
                      actionLabel: 'Clear filters',
                      onAction: () {},
                    ),
                  ),
                ]),

                _Section(label: 'ErrorView', children: [
                  SizedBox(
                    height: 200,
                    child: ErrorView(
                      message: 'Cannot reach the server. Check your connection.',
                      onRetry: () {},
                    ),
                  ),
                ]),

                const _Section(label: 'Skeleton — TutorCard', children: [
                  TutorCardSkeleton(),
                ]),
                const _Section(label: 'Skeleton — SlotTile', children: [
                  SlotTileSkeleton(),
                ]),
                const _Section(label: 'Skeleton — RequestCard', children: [
                  RequestCardSkeleton(),
                ]),

                const _Section(label: 'SkeletonBox varieties', children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SkeletonBox(height: 18, width: 200),
                    SizedBox(height: 8),
                    SkeletonBox(height: 14),
                    SizedBox(height: 8),
                    SkeletonBox(height: 12, width: 150),
                    SizedBox(height: 8),
                    SkeletonBox(height: 28, width: 80, radius: 6),
                  ]),
                ]),

                _Section(label: 'AppAsyncView — Loading state', children: [
                  SizedBox(
                    height: 120,
                    child: AppAsyncView<List<String>>(
                      future: Future.delayed(const Duration(seconds: 60), () => <String>[]),
                      builder: (data) => const SizedBox(),
                      skeletonBuilder: () => const Column(children: [
                        SlotTileSkeleton(), SlotTileSkeleton(),
                      ]),
                    ),
                  ),
                ]),

                _Section(label: 'Date/time formatters', children: [
                  _FormatterRow('dateTime', AppFormatters.dateTime(DateTime.now())),
                  _FormatterRow('date', AppFormatters.date(DateTime.now())),
                  _FormatterRow('time', AppFormatters.time(DateTime.now())),
                  _FormatterRow('remaining (23h)', AppFormatters.remaining(
                    DateTime.now().add(const Duration(hours: 23, minutes: 32)),
                  )),
                  _FormatterRow('remaining (past)', AppFormatters.remaining(
                    DateTime.now().subtract(const Duration(hours: 1)),
                  )),
                  _FormatterRow('duration', AppFormatters.duration(
                    DateTime.now(),
                    DateTime.now().add(const Duration(hours: 1, minutes: 30)),
                  )),
                ]),

                _Section(label: 'Dialogs and Snackbars', children: [
                  Wrap(spacing: 8, children: [
                    OutlinedButton(
                      onPressed: () async {
                        final ok = await showConfirmDialog(
                          context,
                          title:   'Cancel request',
                          message: 'This request will be cancelled. This cannot be undone.',
                          confirmLabel: 'Cancel request',
                          destructive: true,
                        );
                        if (ok && context.mounted) {
                          showSuccessSnackbar(context, 'Request cancelled.');
                        }
                      },
                      child: const Text('Confirm dialog (destructive)'),
                    ),
                    OutlinedButton(
                      onPressed: () => showSuccessSnackbar(context, 'Profile saved.'),
                      child: const Text('Success snackbar'),
                    ),
                    OutlinedButton(
                      onPressed: () => showErrorSnackbar(context, 'Cannot reach the server.'),
                      child: const Text('Error snackbar'),
                    ),
                  ]),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String        label;
  final List<Widget>  children;
  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppLayout.space32),
        Text(label, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppLayout.space4),
        const Divider(),
        const SizedBox(height: AppLayout.space12),
        ...children,
      ],
    );
  }
}

class _FormatterRow extends StatelessWidget {
  final String label;
  final String value;
  const _FormatterRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.space8),
      child: Row(children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: tt.labelMedium?.copyWith(fontFamily: 'monospace')),
        ),
        Text(value, style: tt.bodyMedium),
      ]),
    );
  }
}
