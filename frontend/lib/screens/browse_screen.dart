import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../models/subject.dart';
import '../models/tutor.dart';
import '../services/subject_service.dart';
import '../services/tutor_service.dart';
import '../widgets/tutor_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/empty_state.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  // Filter state
  int?      _subjectId;
  String?   _mode;       // null | 'ONLINE' | 'ON_CAMPUS'
  DateTime? _date;

  // Data
  late Future<List<Subject>>     _subjectsFuture;
  late Future<List<TutorSummary>> _tutorsFuture;

  bool get _hasFilters => _subjectId != null || _mode != null || _date != null;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = context.read<SubjectService>().list();
    _reload();
  }

  void _reload() {
    final svc = context.read<TutorService>();
    setState(() {
      _tutorsFuture = svc.search(
        subjectId: _subjectId,
        mode:      _mode,
        date:      _date != null ? AppFormatters.apiDate(_date!) : null,
      );
    });
  }

  void _resetFilters() {
    setState(() {
      _subjectId = null;
      _mode      = null;
      _date      = null;
    });
    _reload();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:      context,
      initialDate:  _date ?? DateTime.now(),
      firstDate:    DateTime.now(),
      lastDate:     DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= AppLayout.desktopBreakpoint;

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
            child: Text('Browse Tutors',
                style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(height: AppLayout.space16),

          // Filter bar
          _FilterBar(
            subjectsFuture: _subjectsFuture,
            selectedSubjectId: _subjectId,
            selectedMode: _mode,
            selectedDate: _date,
            hasFilters: _hasFilters,
            onSubjectChanged: (id) { setState(() => _subjectId = id); _reload(); },
            onModeChanged:    (m)  { setState(() => _mode = m);       _reload(); },
            onDatePick:       _pickDate,
            onDateClear:      () { setState(() => _date = null);      _reload(); },
            onReset:          _resetFilters,
          ),
          const SizedBox(height: AppLayout.space16),

          // Results
          Expanded(
            child: FutureBuilder<List<TutorSummary>>(
              future: _tutorsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _SkeletonGrid(isWide: isWide, width: width);
                }
                if (snap.hasError) {
                  return _ErrorRetry(
                    message: snap.error.toString(), onRetry: _reload,
                  );
                }
                final tutors = snap.data!;
                if (tutors.isEmpty) {
                  return _hasFilters
                      ? EmptyState(
                          icon: Icons.search_off_outlined,
                          message: 'No tutors match these filters.',
                          actionLabel: 'Reset filters',
                          onAction: _resetFilters,
                        )
                      : const EmptyState(
                          icon: Icons.school_outlined,
                          message:
                              'No tutors yet. Register as a tutor to be the first.',
                        );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppLayout.space16),
                      child: Text(
                        '${tutors.length} ${tutors.length == 1 ? 'tutor' : 'tutors'} available',
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: AppLayout.space12),

                    // Grid
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => _reload(),
                        child: _TutorGrid(tutors: tutors, screenWidth: width),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------
class _FilterBar extends StatelessWidget {
  final Future<List<Subject>> subjectsFuture;
  final int?      selectedSubjectId;
  final String?   selectedMode;
  final DateTime? selectedDate;
  final bool      hasFilters;
  final void Function(int?)    onSubjectChanged;
  final void Function(String?) onModeChanged;
  final VoidCallback onDatePick;
  final VoidCallback onDateClear;
  final VoidCallback onReset;

  const _FilterBar({
    required this.subjectsFuture,
    required this.selectedSubjectId,
    required this.selectedMode,
    required this.selectedDate,
    required this.hasFilters,
    required this.onSubjectChanged,
    required this.onModeChanged,
    required this.onDatePick,
    required this.onDateClear,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final tt  = Theme.of(context).textTheme;
    final isNarrow = MediaQuery.of(context).size.width < AppLayout.mobileBreakpoint;

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.space16, vertical: AppLayout.space12),
            child: isNarrow
                ? _buildNarrow(context, tt)
                : _buildWide(context, tt),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildWide(BuildContext ctx, TextTheme tt) {
    return Row(
      children: [
        // Subject dropdown
        Expanded(flex: 2, child: _SubjectDropdown(
          future: subjectsFuture,
          value: selectedSubjectId,
          onChanged: onSubjectChanged,
        )),
        const SizedBox(width: AppLayout.space12),

        // Mode segmented
        _ModeSegmented(value: selectedMode, onChanged: onModeChanged),
        const SizedBox(width: AppLayout.space12),

        // Date picker
        _DatePickerButton(
          date: selectedDate,
          onPick: onDatePick,
          onClear: onDateClear,
        ),
        if (hasFilters) ...[
          const SizedBox(width: AppLayout.space12),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.clear_all_outlined, size: 16),
            label: const Text('Reset'),
          ),
        ],
      ],
    );
  }

  Widget _buildNarrow(BuildContext ctx, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubjectDropdown(
          future: subjectsFuture,
          value: selectedSubjectId,
          onChanged: onSubjectChanged,
        ),
        const SizedBox(height: AppLayout.space8),
        Row(
          children: [
            Expanded(
              child: _ModeSegmented(value: selectedMode, onChanged: onModeChanged),
            ),
            const SizedBox(width: AppLayout.space8),
            _DatePickerButton(
              date: selectedDate,
              onPick: onDatePick,
              onClear: onDateClear,
            ),
          ],
        ),
        if (hasFilters) ...[
          const SizedBox(height: AppLayout.space8),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.clear_all_outlined, size: 16),
            label: const Text('Reset filters'),
          ),
        ],
      ],
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  final Future<List<Subject>> future;
  final int?    value;
  final void Function(int?) onChanged;

  const _SubjectDropdown({
    required this.future, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Subject>>(
      future: future,
      builder: (ctx, snap) {
        final subjects = snap.data ?? [];
        return DropdownButtonFormField<int?>(
          initialValue: value,
          decoration: const InputDecoration(
            labelText: 'Subject',
            prefixIcon: Icon(Icons.book_outlined, size: 16),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All subjects')),
            ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

class _ModeSegmented extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;
  const _ModeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = {value};
    return SegmentedButton<String?>(
      segments: const [
        ButtonSegment(value: null,         label: Text('Any')),
        ButtonSegment(value: 'ONLINE',     label: Text('Online')),
        ButtonSegment(value: 'ON_CAMPUS',  label: Text('On campus')),
      ],
      selected: selected,
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;
  const _DatePickerButton({required this.date, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.calendar_today_outlined, size: 15),
        label: const Text('Date'),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.calendar_today_outlined, size: 15),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppFormatters.date(date!)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Responsive grid of TutorCard
// ---------------------------------------------------------------------------
class _TutorGrid extends StatelessWidget {
  final List<TutorSummary> tutors;
  final double screenWidth;
  const _TutorGrid({required this.tutors, required this.screenWidth});

  int get _columns {
    if (screenWidth >= AppLayout.desktopBreakpoint) return 3;
    if (screenWidth >= AppLayout.mobileBreakpoint)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppLayout.space16, 0, AppLayout.space16, AppLayout.space24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   _columns,
        mainAxisSpacing:  AppLayout.space12,
        crossAxisSpacing: AppLayout.space12,
        childAspectRatio: _columns == 1 ? 2.4 : _columns == 2 ? 1.1 : 0.95,
      ),
      itemCount: tutors.length,
      itemBuilder: (_, i) => TutorCard(tutor: tutors[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton grid (shown while loading)
// ---------------------------------------------------------------------------
class _SkeletonGrid extends StatelessWidget {
  final bool isWide;
  final double width;
  const _SkeletonGrid({required this.isWide, required this.width});

  int get _columns {
    if (width >= AppLayout.desktopBreakpoint) return 3;
    if (width >= AppLayout.mobileBreakpoint)  return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppLayout.space16, 0, AppLayout.space16, AppLayout.space24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   _columns,
        mainAxisSpacing:  AppLayout.space12,
        crossAxisSpacing: AppLayout.space12,
        childAspectRatio: _columns == 1 ? 2.4 : _columns == 2 ? 1.1 : 0.95,
      ),
      itemCount: _columns * 2,
      itemBuilder: (_, __) => const TutorCardSkeleton(),
    );
  }
}

// ---------------------------------------------------------------------------
// Error retry view
// ---------------------------------------------------------------------------
class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 32, color: AppColors.muted),
          const SizedBox(height: AppLayout.space12),
          Text(message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  )),
          const SizedBox(height: AppLayout.space16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
