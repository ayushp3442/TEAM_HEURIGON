import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/tutor.dart';
import '../models/slot.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';
import '../services/tutor_service.dart';
import '../services/request_service.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/mode_chip.dart';
import '../widgets/slot_tile.dart';
import '../widgets/skeleton.dart';
import '../core/api_client.dart';

class TutorDetailScreen extends StatefulWidget {
  final int tutorId;
  const TutorDetailScreen({super.key, required this.tutorId});

  @override
  State<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends State<TutorDetailScreen> {
  late Future<TutorProfile>  _profileFuture;
  late Future<List<Slot>>    _slotsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final svc = context.read<TutorService>();
    setState(() {
      _profileFuture = svc.getById(widget.tutorId);
      _slotsFuture   = svc.getSlotsForTutor(widget.tutorId);
    });
  }

  void _reloadSlots() {
    setState(() {
      _slotsFuture = context.read<TutorService>().getSlotsForTutor(widget.tutorId);
    });
  }

  Future<void> _openRequestDialog(
      BuildContext ctx, Slot slot, TutorProfile profile) async {
    final auth = ctx.read<AuthProvider>();
    if (auth.isTutor) return; // tutors can't request

    final sent = await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _RequestDialog(
        slot:     slot,
        profile:  profile,
        onSuccess: () {
          Navigator.of(ctx, rootNavigator: true).pop(true);
        },
      ),
    );
    if (sent == true && mounted) {
      // Show thank-you dialog
      await showDialog(
        context: context,
        builder: (_) => const _ThankYouDialog(),
      );
      _reloadSlots();
    }
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();
    final isTutor = auth.isTutor;
    final width  = MediaQuery.of(context).size.width;
    final isMobile = width < AppLayout.mobileBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => context.go('/browse'),
        ),
        title: const Text('Tutor profile'),
      ),
      body: FutureBuilder<TutorProfile>(
        future: _profileFuture,
        builder: (ctx, profileSnap) {
          if (profileSnap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(AppLayout.space16),
              child: Column(children: [
                TutorCardSkeleton(),
                SizedBox(height: AppLayout.space16),
                SlotTileSkeleton(), SlotTileSkeleton(), SlotTileSkeleton(),
              ]),
            );
          }
          if (profileSnap.hasError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, color: AppColors.muted),
                const SizedBox(height: 8),
                Text(profileSnap.error.toString()),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: _load, child: const Text('Retry')),
              ]),
            );
          }
          final profile = profileSnap.data!;
          final bool isOwnProfile = isTutor &&
              auth.user?.id == profile.userId;

          Widget body = SingleChildScrollView(
            padding: const EdgeInsets.all(AppLayout.space16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    _ProfileHeader(profile: profile, initials: _initials(profile.name)),
                    if (isOwnProfile) ...[
                      const SizedBox(height: AppLayout.space12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppLayout.space12, vertical: AppLayout.space8),
                        decoration: BoxDecoration(
                          color: AppColors.pendingBg,
                          borderRadius: AppTheme.borderRadius,
                          border: Border.all(
                              color: AppColors.pending.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.pending),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is your own profile. Students see it this way.',
                              style: tt.bodySmall
                                  ?.copyWith(color: AppColors.pending),
                            ),
                          ),
                        ]),
                      ),
                    ],
                    const SizedBox(height: AppLayout.space24),

                    // Slots section
                    Text('Available slots', style: tt.headlineMedium),
                    const SizedBox(height: AppLayout.space12),
                    _SlotsSection(
                      future: _slotsFuture,
                      onRequest: isTutor
                          ? null
                          : (slot) => _openRequestDialog(ctx, slot, profile),
                      profile: profile,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );

          // Mobile sticky bottom bar — "Request a session"
          if (isMobile && !isTutor) {
            body = Stack(
              children: [
                body,
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        AppLayout.space16, AppLayout.space12,
                        AppLayout.space16, AppLayout.space20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: FutureBuilder<List<Slot>>(
                      future: _slotsFuture,
                      builder: (_, snap) {
                        final slots = snap.data?.where((s) => !s.booked).toList() ?? [];
                        if (slots.isEmpty) return const SizedBox.shrink();
                        return FilledButton(
                          onPressed: slots.length == 1
                              ? () => _openRequestDialog(ctx, slots.first, profile)
                              : () => _scrollToSlots(ctx),
                          child: const Text('Request a session'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return body;
        },
      ),
    );
  }

  void _scrollToSlots(BuildContext ctx) {
    // Scrolls user down to the slots list on mobile
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}


// ---------------------------------------------------------------------------
// Profile Header
// ---------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final TutorProfile profile;
  final String       initials;
  const _ProfileHeader({required this.profile, required this.initials});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(initials: initials, size: 48),
              const SizedBox(width: AppLayout.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: tt.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.department} · Year ${profile.yearOfStudy}',
                      style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: AppLayout.space16),
            Text(profile.bio, style: tt.bodyMedium),
          ],
          const SizedBox(height: AppLayout.space12),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: profile.subjects.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(s.name, style: tt.labelSmall),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slots section
// ---------------------------------------------------------------------------
class _SlotsSection extends StatelessWidget {
  final Future<List<Slot>>       future;
  final void Function(Slot)?     onRequest;
  final TutorProfile             profile;

  const _SlotsSection({
    required this.future,
    required this.onRequest,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Slot>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Column(children: [
            SlotTileSkeleton(), SlotTileSkeleton(), SlotTileSkeleton(),
          ]);
        }
        if (snap.hasError) {
          return Text(snap.error.toString());
        }
        final slots = snap.data!;
        if (slots.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppLayout.space24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppTheme.borderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No open slots right now. Check back later.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          );
        }
        return Column(
          children: slots
              .map((s) => SlotTile(
                    slot:      s,
                    onRequest: onRequest != null ? () => onRequest!(s) : null,
                  ))
              .toList(),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Request dialog
// ---------------------------------------------------------------------------
class _RequestDialog extends StatefulWidget {
  final Slot        slot;
  final TutorProfile profile;
  final VoidCallback onSuccess;
  const _RequestDialog({
    required this.slot, required this.profile, required this.onSuccess,
  });

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final _formKey   = GlobalKey<FormState>();
  final _msgCtrl   = TextEditingController();
  Subject? _selectedSubject;
  bool _submitting = false;
  String? _error;

  static const int _maxMsg = 300;

  @override
  void initState() {
    super.initState();
    if (widget.profile.subjects.length == 1) {
      _selectedSubject = widget.profile.subjects.first;
    }
  }

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      setState(() => _error = 'Please select a subject.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      await context.read<RequestService>().create(
        slotId:    widget.slot.id,
        subjectId: _selectedSubject!.id,
        message:   _msgCtrl.text.trim(),
      );
      widget.onSuccess();
    } catch (e) {
      setState(() => _error = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final slot = widget.slot;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Request session'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slot summary
              Container(
                padding: const EdgeInsets.all(AppLayout.space12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppTheme.borderRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.dateTime(slot.startTime),
                      style: tt.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.time(slot.startTime)} – ${AppFormatters.time(slot.endTime)}',
                      style: tt.bodySmall,
                    ),
                    const SizedBox(height: AppLayout.space4),
                    ModeChip(mode: slot.mode),
                  ],
                ),
              ),
              const SizedBox(height: AppLayout.space16),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppLayout.space8),
                  decoration: BoxDecoration(
                    color: AppColors.declinedBg,
                    borderRadius: AppTheme.borderRadius,
                    border: Border.all(
                        color: AppColors.declined.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        size: 14, color: AppColors.declined),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_error!,
                          style: tt.bodySmall
                              ?.copyWith(color: AppColors.declined)),
                    ),
                  ]),
                ),
                const SizedBox(height: AppLayout.space12),
              ],

              // Subject picker
              Text('Subject', style: tt.labelMedium),
              const SizedBox(height: AppLayout.space4),
              DropdownButtonFormField<Subject>(
                initialValue: _selectedSubject,
                hint: const Text('Select a subject'),
                items: widget.profile.subjects
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (s) => setState(() => _selectedSubject = s),
                validator: (v) => v == null ? 'Select a subject.' : null,
              ),
              const SizedBox(height: AppLayout.space16),

              // Message field
              Text('Message (optional)', style: tt.labelMedium),
              const SizedBox(height: AppLayout.space4),
              ValueListenableBuilder(
                valueListenable: _msgCtrl,
                builder: (_, __, ___) => TextFormField(
                  controller: _msgCtrl,
                  maxLines:   4,
                  maxLength:  _maxMsg,
                  decoration: InputDecoration(
                    hintText:  'What do you need help with?',
                    counterText:
                        '${_msgCtrl.text.length}/$_maxMsg',
                  ),
                  validator: (v) {
                    if ((v?.length ?? 0) > _maxMsg) {
                      return 'Max $_maxMsg characters.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.onPrimary),
                )
              : const Text('Send request'),
        ),
      ],
    );
  }
}

class _ThankYouDialog extends StatelessWidget {
  const _ThankYouDialog();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppLayout.space12),
            decoration: BoxDecoration(
              color: AppColors.acceptedBg,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.accepted.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.check_outlined, size: 28, color: AppColors.accepted,
            ),
          ),
          const SizedBox(height: AppLayout.space16),
          Text('Request sent', style: tt.headlineMedium),
          const SizedBox(height: AppLayout.space8),
          Text(
            'The tutor will review your request and let you know — once accepted, a chat opens 1 hour before the session.',
            style: tt.bodyMedium?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/browse');
          },
          child: const Text('Back to tutors'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/my-requests');
          },
          child: const Text('View my requests'),
        ),
      ],
    );
  }
}
