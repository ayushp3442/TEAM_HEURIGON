import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/tutor.dart';
import '../models/slot.dart';
import '../models/session_request.dart';
import '../providers/auth_provider.dart';
import '../services/tutor_service.dart';
import '../services/slot_service.dart';
import '../services/request_service.dart';
import '../widgets/slot_tile.dart';
import '../widgets/request_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/dialogs.dart';
import '../core/api_client.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  TutorProfile?             _profile;
  bool                      _profileLoading = true;

  late Future<List<Slot>>            _slotsFuture;
  late Future<List<SessionRequest>>  _requestsFuture;

  RequestStatus? _requestFilter; // null = all

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadProfile();
    _loadSlots();
    _loadRequests();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _profileLoading = true);
    try {
      _profile = await context.read<TutorService>().me();
    } catch (_) {
      _profile = null;
    } finally {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  void _loadSlots() {
    setState(() {
      _slotsFuture = context.read<SlotService>().mine();
    });
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = context.read<RequestService>().incoming();
    });
  }

  Future<void> _deleteSlot(int id) async {
    final ok = await showConfirmDialog(
      context,
      title:        'Delete slot',
      message:      'This slot will be removed. Students will no longer be able to request it.',
      confirmLabel: 'Delete',
      destructive:  true,
    );
    if (!ok || !mounted) return;
    try {
      await context.read<SlotService>().delete(id);
      if (mounted) {
        showSuccessSnackbar(context, 'Slot deleted.');
        _loadSlots();
      }
    } catch (e) {
      if (mounted) showErrorSnackbar(context, ApiClient.errorMessage(e));
    }
  }

  Future<void> _handleRequestUpdate(int id, String status) async {
    final verb = status == 'ACCEPTED' ? 'Accept' : 'Decline';
    final ok = await showConfirmDialog(
      context,
      title:        '$verb request',
      message:      status == 'ACCEPTED'
          ? 'Accept this request? Other requests for this slot will be declined.'
          : 'Decline this request?',
      confirmLabel: verb,
      destructive:  status == 'DECLINED',
    );
    if (!ok || !mounted) return;
    try {
      await context.read<RequestService>().updateStatus(id, status);
      if (mounted) {
        if (status == 'ACCEPTED') {
          showSuccessSnackbar(
            context,
            'Request accepted. Other requests for this slot were declined.',
          );
        } else {
          showSuccessSnackbar(context, 'Request declined.');
        }
        _loadRequests();
        _loadSlots(); // slot may now be marked booked
      }
    } catch (e) {
      if (mounted) showErrorSnackbar(context, ApiClient.errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppLayout.space16, AppLayout.space24,
                AppLayout.space16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Dashboard', style: tt.displaySmall),
                      Text(
                        auth.displayName,
                        style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/dashboard/profile'),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),

          // No profile banner
          if (!_profileLoading && _profile == null) ...[
            const SizedBox(height: AppLayout.space16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.space16),
              child: _NoProfileBanner(),
            ),
          ],

          // Summary row (computed when data loaded)
          const SizedBox(height: AppLayout.space16),
          _SummaryRow(
            slotsFuture:    _slotsFuture,
            requestsFuture: _requestsFuture,
          ),
          const SizedBox(height: AppLayout.space4),

          // Tab bar
          Container(
            color: AppColors.surface,
            child: Column(children: [
              const Divider(height: 1),
              TabBar(
                controller: _tabCtrl,
                tabs: const [Tab(text: 'Requests'), Tab(text: 'My slots')],
              ),
              const Divider(height: 1),
            ]),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // ── Requests tab (F9) ──
                _RequestsTab(
                  future:         _requestsFuture,
                  filter:         _requestFilter,
                  onFilterChange: (f) => setState(() => _requestFilter = f),
                  onUpdateStatus: _handleRequestUpdate,
                  onRefresh:      _loadRequests,
                ),

                // ── Slots tab (F8) ──
                _SlotsTab(
                  future:      _slotsFuture,
                  hasProfile:  _profile != null,
                  onDelete:    _deleteSlot,
                  onRefresh:   _loadSlots,
                  onSlotAdded: _loadSlots,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// No profile banner
// ---------------------------------------------------------------------------
class _NoProfileBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppLayout.space16),
      decoration: BoxDecoration(
        color: AppColors.pendingBg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.pending.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.pending, size: 18),
          const SizedBox(width: AppLayout.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set up your tutor profile',
                    style: tt.labelLarge?.copyWith(color: AppColors.pending)),
                Text(
                  'Students cannot find you until you create a profile.',
                  style: tt.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.space12),
          FilledButton(
            onPressed: () => context.go('/dashboard/profile'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Create profile'),
          ),
        ],
      ),
    );
  }





  
}

// ---------------------------------------------------------------------------
// Summary row — 3 plain figures with dividers, NOT three identical cards
// ---------------------------------------------------------------------------
class _SummaryRow extends StatelessWidget {
  final Future<List<Slot>>           slotsFuture;
  final Future<List<SessionRequest>> requestsFuture;

  const _SummaryRow({required this.slotsFuture, required this.requestsFuture});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return FutureBuilder(
      future: Future.wait([slotsFuture, requestsFuture]),
      builder: (ctx, AsyncSnapshot<List<dynamic>> snap) {
        final slots    = (snap.data?[0] as List<Slot>?)           ?? [];
        final requests = (snap.data?[1] as List<SessionRequest>?) ?? [];

        final pending  = requests.where((r) => r.status == RequestStatus.pending).length;
        final upcoming = requests.where((r) =>
            r.status == RequestStatus.accepted &&
            r.slot.startTime.isAfter(now)).length;
        final openSlots = slots.where((s) => !s.booked).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppLayout.space16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppTheme.borderRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _SummaryFigure(
                  value: pending.toString(),
                  label: 'Pending requests',
                  color: pending > 0 ? AppColors.pending : AppColors.muted,
                ),
                const VerticalDivider(width: 1),
                _SummaryFigure(
                  value: upcoming.toString(),
                  label: 'Upcoming sessions',
                ),
                const VerticalDivider(width: 1),
                _SummaryFigure(
                  value: openSlots.toString(),
                  label: 'Open slots',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryFigure extends StatelessWidget {
  final String  value;
  final String  label;
  final Color   color;

  const _SummaryFigure({
    required this.value,
    required this.label,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppLayout.space12, horizontal: AppLayout.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: tt.displaySmall?.copyWith(color: color, fontSize: 22)),
            Text(label, style: tt.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Requests tab (F9)
// ---------------------------------------------------------------------------
class _RequestsTab extends StatelessWidget {
  final Future<List<SessionRequest>>     future;
  final RequestStatus?                   filter;
  final void Function(RequestStatus?)    onFilterChange;
  final Future<void> Function(int, String) onUpdateStatus;
  final VoidCallback                     onRefresh;

  const _RequestsTab({
    required this.future,
    required this.filter,
    required this.onFilterChange,
    required this.onUpdateStatus,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionRequest>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _SkeletonList();
        }
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off_outlined, color: AppColors.muted),
              const SizedBox(height: 8),
              Text(snap.error.toString()),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_outlined, size: 16),
                label: const Text('Try again'),
              ),
            ]),
          );
        }
        final all = snap.data!;
        final filtered = filter == null
            ? all
            : all.where((r) => r.status == filter).toList();

        return Column(
          children: [
            // Filter chips
            _FilterRow(current: filter, onChange: onFilterChange),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppLayout.space32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 28, color: AppColors.muted),
                            const SizedBox(height: AppLayout.space12),
                            Text(
                              all.isEmpty
                                  ? 'No requests yet. Post more slots to get discovered.'
                                  : 'No ${filter?.label.toLowerCase() ?? ''} requests.',
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.muted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppLayout.space16, AppLayout.space12,
                            AppLayout.space16, AppLayout.space24),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => RequestCard(
                          request:        filtered[i],
                          isTutorView:    true,
                          onUpdateStatus: onUpdateStatus,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  final RequestStatus?                current;
  final void Function(RequestStatus?) onChange;

  const _FilterRow({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final options = <(String, RequestStatus?)>[
      ('All',      null),
      ('Pending',  RequestStatus.pending),
      ('Accepted', RequestStatus.accepted),
      ('Declined', RequestStatus.declined),
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.space16, vertical: AppLayout.space8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: options.map((opt) {
            final selected = current == opt.$2;
            return Padding(
              padding: const EdgeInsets.only(right: AppLayout.space8),
              child: GestureDetector(
                onTap: () => onChange(opt.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color:        selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    opt.$1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected ? AppColors.onPrimary : AppColors.muted,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slots tab (F8)
// ---------------------------------------------------------------------------
class _SlotsTab extends StatelessWidget {
  final Future<List<Slot>> future;
  final bool               hasProfile;
  final Future<void> Function(int) onDelete;
  final VoidCallback               onRefresh;
  final VoidCallback               onSlotAdded;

  const _SlotsTab({
    required this.future,
    required this.hasProfile,
    required this.onDelete,
    required this.onRefresh,
    required this.onSlotAdded,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return FutureBuilder<List<Slot>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _SkeletonList();
        }
        if (snap.hasError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off_outlined, color: AppColors.muted),
              const SizedBox(height: 8),
              Text(snap.error.toString()),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRefresh, child: const Text('Retry')),
            ]),
          );
        }
        final slots = snap.data!;

        return Column(
          children: [
            // Section header + Add button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppLayout.space16, AppLayout.space12,
                  AppLayout.space16, AppLayout.space8),
              child: Row(
                children: [
                  Text('${slots.length} ${slots.length == 1 ? 'slot' : 'slots'}',
                      style: tt.bodySmall),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: hasProfile
                        ? () => _showAddSlotDialog(ctx, onSlotAdded)
                        : null,
                    icon: const Icon(Icons.add_outlined, size: 16),
                    label: const Text('Add slot'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            // Slot list
            Expanded(
              child: slots.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppLayout.space32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 28, color: AppColors.muted),
                            const SizedBox(height: AppLayout.space12),
                            Text(
                              hasProfile
                                  ? 'No slots yet. Add one so students can find you.'
                                  : 'Create your profile first to add slots.',
                              style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                              textAlign: TextAlign.center,
                            ),
                            if (hasProfile) ...[
                              const SizedBox(height: AppLayout.space16),
                              OutlinedButton.icon(
                                onPressed: () => _showAddSlotDialog(ctx, onSlotAdded),
                                icon: const Icon(Icons.add_outlined, size: 16),
                                label: const Text('Add a slot'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppLayout.space16, 0,
                            AppLayout.space16, AppLayout.space24),
                        itemCount: slots.length,
                        itemBuilder: (_, i) => SlotTile(
                          slot: slots[i],
                          onDelete: slots[i].booked ? null : () => onDelete(slots[i].id),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  static void _showAddSlotDialog(BuildContext ctx, VoidCallback onAdded) {
    showDialog(
      context: ctx,
      builder: (_) => _AddSlotDialog(
        onAdded: onAdded,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Slot dialog
// ---------------------------------------------------------------------------
class _AddSlotDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddSlotDialog({required this.onAdded});

  @override
  State<_AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<_AddSlotDialog> {
  final _locationCtrl = TextEditingController();

  DateTime?  _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String     _mode = 'ONLINE';
  bool       _saving = false;
  String?    _error;

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  DateTime? get _startDt {
    if (_date == null || _startTime == null) return null;
    return DateTime(_date!.year, _date!.month, _date!.day,
        _startTime!.hour, _startTime!.minute);
  }

  DateTime? get _endDt {
    if (_date == null || _endTime == null) return null;
    return DateTime(_date!.year, _date!.month, _date!.day,
        _endTime!.hour, _endTime!.minute);
  }

  String? _validate() {
    final start = _startDt;
    final end   = _endDt;
    if (_date == null) return 'Select a date.';
    if (_startTime == null) return 'Select a start time.';
    if (_endTime == null)   return 'Select an end time.';
    if (start == null || end == null) return 'Invalid date or time.';
    if (start.isBefore(DateTime.now().add(const Duration(minutes: 2)))) {
      return 'Start time must be at least 2 minutes from now.';
    }
    if (!end.isAfter(start)) {
      return 'End time must be after start time.';
    }
    if (end.difference(start).inMinutes < 15) {
      return 'Session must be at least 15 minutes long.';
    }
    if (_locationCtrl.text.trim().isEmpty) {
      return _mode == 'ONLINE'
          ? 'Meeting link is required.'
          : 'Location is required.';
    }
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _saving = true; _error = null; });
    try {
      await context.read<SlotService>().create(
        startTime:      _startDt!,
        endTime:        _endDt!,
        mode:           _mode,
        locationOrLink: _locationCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onAdded();
        showSuccessSnackbar(context, 'Slot added.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Add slot'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          style: tt.bodySmall?.copyWith(color: AppColors.declined)),
                    ),
                  ]),
                ),
                const SizedBox(height: AppLayout.space12),
              ],

              // Date
              _PickerRow(
                label: 'Date',
                value: _date != null ? AppFormatters.date(_date!) : null,
                placeholder: 'Pick a date',
                icon: Icons.calendar_today_outlined,
                onTap: () async {
                  final d = await showDatePicker(
                    context:    context,
                    initialDate: _date ?? DateTime.now().add(const Duration(hours: 1)),
                    firstDate:  DateTime.now(),
                    lastDate:   DateTime.now().add(const Duration(days: 90)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: Theme.of(ctx).colorScheme.copyWith(
                            primary: AppColors.primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) setState(() => _date = d);
                },
              ),
              const SizedBox(height: AppLayout.space12),

              // Start + end time
              Row(
                children: [
                  Expanded(
                    child: _PickerRow(
                      label: 'Start',
                      value: _startTime?.format(context),
                      placeholder: '09:00 AM',
                      icon: Icons.access_time_outlined,
                      onTap: () async {
                        final t = await showTimePicker(
                          context:     context,
                          initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (t != null) setState(() => _startTime = t);
                      },
                    ),
                  ),
                  const SizedBox(width: AppLayout.space12),
                  Expanded(
                    child: _PickerRow(
                      label: 'End',
                      value: _endTime?.format(context),
                      placeholder: '10:00 AM',
                      icon: Icons.access_time_outlined,
                      onTap: () async {
                        final t = await showTimePicker(
                          context:     context,
                          initialTime: _endTime ??
                              (_startTime != null
                                  ? TimeOfDay(
                                      hour: _startTime!.hour + 1,
                                      minute: _startTime!.minute)
                                  : const TimeOfDay(hour: 10, minute: 0)),
                        );
                        if (t != null) setState(() => _endTime = t);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Start must be ≥ 2 min from now · Duration ≥ 5 min.',
                style: tt.bodySmall,
              ),
              const SizedBox(height: AppLayout.space12),

              // Mode
              Text('Mode', style: tt.labelMedium),
              const SizedBox(height: AppLayout.space4),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'ONLINE',
                    label: Text('Online'),
                    icon: Icon(Icons.videocam_outlined, size: 14),
                  ),
                  ButtonSegment(
                    value: 'ON_CAMPUS',
                    label: Text('On campus'),
                    icon: Icon(Icons.location_on_outlined, size: 14),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: AppLayout.space12),

              // Location / link
              Text(
                _mode == 'ONLINE' ? 'Meeting link *' : 'Location *',
                style: tt.labelMedium,
              ),
              const SizedBox(height: AppLayout.space4),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: _mode == 'ONLINE'
                      ? 'https://meet.google.com/…'
                      : 'e.g. Library Room 204',
                  prefixIcon: Icon(
                    _mode == 'ONLINE'
                        ? Icons.link_outlined
                        : Icons.location_on_outlined,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.onPrimary))
              : const Text('Add slot'),
        ),
      ],
    );
  }
}

// Picker row helper (date/time selector)
class _PickerRow extends StatelessWidget {
  final String     label;
  final String?    value;
  final String     placeholder;
  final IconData   icon;
  final VoidCallback onTap;

  const _PickerRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelMedium),
        const SizedBox(height: AppLayout.space4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppTheme.borderRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.muted),
                const SizedBox(width: 6),
                Text(
                  value ?? placeholder,
                  style: tt.bodyMedium?.copyWith(
                    color: value != null ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Skeleton list helper
class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppLayout.space16),
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: AppLayout.space12),
        child: RequestCardSkeleton(),
      ),
    );
  }
}
