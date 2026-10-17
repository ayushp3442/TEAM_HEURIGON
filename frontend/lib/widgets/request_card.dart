import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/session_request.dart';
import 'status_chip.dart';
import 'mode_chip.dart';

// RequestCard — used in My Requests (student) and Incoming Requests (tutor).
// Displays tutor/student name, subject, slot, message, status.
// PENDING: cancel button (student view)
// ACCEPTED: meeting link with copy + chat entry point
class RequestCard extends StatelessWidget {
  final SessionRequest request;
  final bool           isTutorView;     // true = show student name, no cancel
  final Future<void> Function(int id)? onCancel;   // student only
  final Future<void> Function(int id, String status)? onUpdateStatus; // tutor only
  final VoidCallback? onRefresh;

  const RequestCard({
    super.key,
    required this.request,
    this.isTutorView = false,
    this.onCancel,
    this.onUpdateStatus,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final tt  = Theme.of(context).textTheme;
    final req = request;

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.space12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: name + status chip ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.space16, AppLayout.space12,
                AppLayout.space12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTutorView
                            ? req.student.name
                            : req.tutor.name,
                        style: tt.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        req.subject.name,
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppLayout.space8),
                StatusChip(status: req.status),
              ],
            ),
          ),

          // ── Slot details ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.space16, AppLayout.space8,
                AppLayout.space16, 0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${AppFormatters.dateTime(req.slot.startTime)} – '
                    '${AppFormatters.time(req.slot.endTime)}',
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppLayout.space8),
                ModeChipStr(mode: req.slot.mode),
              ],
            ),
          ),

          // ── Message ──
          if (req.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.space16, AppLayout.space8,
                  AppLayout.space16, 0),
              child: Text(
                '"${req.message}"',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── ACCEPTED section ──
          if (req.status == RequestStatus.accepted) ...[
            const SizedBox(height: AppLayout.space12),
            const Divider(height: 1),
            _AcceptedSection(request: req, isTutorView: isTutorView),
          ],

          // ── PENDING actions (student only) ──
          if (!isTutorView && req.status == RequestStatus.pending && onCancel != null) ...[
            const SizedBox(height: AppLayout.space8),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.space16, 0, AppLayout.space16, AppLayout.space12),
              child: _CancelButton(request: req, onCancel: onCancel!),
            ),
          ] else
            const SizedBox(height: AppLayout.space12),

          // ── PENDING actions (tutor only) ──
          if (isTutorView && req.status == RequestStatus.pending && onUpdateStatus != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.space16),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.space16, AppLayout.space8,
                  AppLayout.space16, AppLayout.space12),
              child: _TutorActions(request: req, onUpdateStatus: onUpdateStatus!),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accepted section: location/link + chat state
// ---------------------------------------------------------------------------
class _AcceptedSection extends StatelessWidget {
  final SessionRequest request;
  final bool           isTutorView;
  const _AcceptedSection({required this.request, required this.isTutorView});

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final slot = request.slot;
    final chat = request.chat;
    final isOnline = slot.mode.toUpperCase() == 'ONLINE';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppLayout.space16, AppLayout.space12,
          AppLayout.space16, AppLayout.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting link or location — prominent with copy button
          if (slot.locationOrLink.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  isOnline ? Icons.link_outlined : Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slot.locationOrLink,
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _CopyButton(text: slot.locationOrLink),
              ],
            ),
            const SizedBox(height: AppLayout.space12),
          ],

          // Chat entry point
          if (chat != null) _ChatEntry(chat: chat, requestId: request.id),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat entry point
// ---------------------------------------------------------------------------
class _ChatEntry extends StatelessWidget {
  final ChatInfo chat;
  final int      requestId;
  const _ChatEntry({required this.chat, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    switch (chat.state) {
      case ChatState.open:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go('/chats/$requestId'),
            icon: const Icon(Icons.chat_outlined, size: 16),
            label: const Text('Open chat'),
          ),
        );

      case ChatState.notStarted:
        return Row(
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Chat opens at ${AppFormatters.time(chat.opensAt)} · '
                '${AppFormatters.remaining(chat.opensAt)}',
                style: tt.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        );

      case ChatState.closed:
        return Row(
          children: [
            const Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              'Chat closed',
              style: tt.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Copy button — copies text to clipboard and briefly shows a checkmark
// ---------------------------------------------------------------------------
class _CopyButton extends StatefulWidget {
  final String text;
  const _CopyButton({required this.text});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _copy,
      tooltip: _copied ? 'Copied!' : 'Copy',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _copied ? Icons.check_outlined : Icons.copy_outlined,
          key: ValueKey(_copied),
          size: 15,
          color: _copied ? AppColors.accepted : AppColors.muted,
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}

// ---------------------------------------------------------------------------
// Cancel button (student)
// ---------------------------------------------------------------------------
class _CancelButton extends StatefulWidget {
  final SessionRequest request;
  final Future<void> Function(int id) onCancel;
  const _CancelButton({required this.request, required this.onCancel});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _loading = false;

  Future<void> _tap() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel request'),
        content: const Text(
          'This request will be cancelled. The tutor will no longer see it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.declined),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await widget.onCancel(widget.request.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.declined,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _loading ? null : _tap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.declined,
        side: const BorderSide(color: AppColors.declined),
      ),
      child: _loading
          ? const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.declined),
            )
          : const Text('Cancel request'),
    );
  }
}

// ---------------------------------------------------------------------------
// Tutor accept / decline buttons
// ---------------------------------------------------------------------------
class _TutorActions extends StatefulWidget {
  final SessionRequest request;
  final Future<void> Function(int id, String status) onUpdateStatus;
  const _TutorActions({required this.request, required this.onUpdateStatus});

  @override
  State<_TutorActions> createState() => _TutorActionsState();
}

class _TutorActionsState extends State<_TutorActions> {
  String? _loading; // 'ACCEPTED' | 'DECLINED'

  Future<void> _act(String status) async {
    setState(() => _loading = status);
    try {
      await widget.onUpdateStatus(widget.request.id, status);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.declined,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: _loading != null ? null : () => _act('DECLINED'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.declined,
            side: const BorderSide(color: AppColors.declined),
          ),
          child: _loading == 'DECLINED'
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.declined))
              : const Text('Decline'),
        ),
        const SizedBox(width: AppLayout.space8),
        FilledButton(
          onPressed: _loading != null ? null : () => _act('ACCEPTED'),
          child: _loading == 'ACCEPTED'
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.onPrimary))
              : const Text('Accept'),
        ),
      ],
    );
  }
}
