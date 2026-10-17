import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/subject.dart';
import '../providers/auth_provider.dart';
import '../services/tutor_service.dart';
import '../services/subject_service.dart';
import '../core/api_client.dart';
import '../widgets/dialogs.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _bioCtrl        = TextEditingController();
  final _deptCtrl       = TextEditingController();
  final _newSubjectCtrl = TextEditingController();

  int?           _yearOfStudy;
  Set<int>       _selectedSubjectIds = {};
  List<Subject>  _allSubjects        = [];
  bool           _isNew              = true; // 404 = creating fresh

  bool           _loadingProfile = true;
  bool           _loadingSubjects = true;
  bool           _saving         = false;
  String?        _serverError;
  String?        _addSubjectError;
  bool           _addingSubject  = false;

  static const int _maxBio = 500;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _deptCtrl.dispose();
    _newSubjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load subjects list and existing profile in parallel
    await Future.wait([_loadSubjects(), _loadProfile()]);
  }

  Future<void> _loadSubjects() async {
    try {
      final subjects = await context.read<SubjectService>().list();
      if (mounted) setState(() { _allSubjects = subjects; _loadingSubjects = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingSubjects = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await context.read<TutorService>().me();
      if (profile != null && mounted) {
        _bioCtrl.text   = profile.bio;
        _deptCtrl.text  = profile.department;
        _yearOfStudy    = profile.yearOfStudy;
        _selectedSubjectIds = profile.subjects.map((s) => s.id).toSet();
        _isNew = false;
      }
    } catch (_) {
      // 404 or network error → blank form
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _addSubject() async {
    final name = _newSubjectCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() { _addingSubject = true; _addSubjectError = null; });
    try {
      final subject = await context.read<SubjectService>().create(name);
      if (mounted) {
        setState(() {
          if (!_allSubjects.any((s) => s.id == subject.id)) {
            _allSubjects = [..._allSubjects, subject];
          }
          _selectedSubjectIds.add(subject.id);
          _newSubjectCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _addSubjectError = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _addingSubject = false);
    }
  }

  Future<void> _save() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectIds.isEmpty) {
      setState(() => _serverError = 'Select at least one subject.');
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<TutorService>().upsertMe(
        bio:        _bioCtrl.text.trim(),
        department: _deptCtrl.text.trim(),
        yearOfStudy: _yearOfStudy!,
        subjectIds: _selectedSubjectIds.toList(),
      );
      if (mounted) {
        showSuccessSnackbar(
          context,
          _isNew
              ? 'Profile created! You can now post availability slots.'
              : 'Tutor profile updated successfully.',
        );
        context.read<AuthProvider>().setHasTutorProfile(true);
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) setState(() => _serverError = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isLoading = _loadingProfile || _loadingSubjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isNew ? 'Create your profile' : 'Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppLayout.space16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isNew) ...[
                          Text('Create your profile', style: tt.displaySmall),
                          const SizedBox(height: AppLayout.space4),
                          Text(
                            'Students will see this when browsing for a tutor.',
                            style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: AppLayout.space24),
                        ],

                        // Server error
                        if (_serverError != null) ...[
                          _ErrorBanner(message: _serverError!),
                          const SizedBox(height: AppLayout.space16),
                        ],

                        // Bio
                        const _SectionLabel(label: 'Bio', hint: 'Tell students who you are and what you teach.'),
                        const SizedBox(height: AppLayout.space8),
                        ValueListenableBuilder(
                          valueListenable: _bioCtrl,
                          builder: (_, __, ___) => TextFormField(
                            controller: _bioCtrl,
                            maxLines:   5,
                            maxLength:  _maxBio,
                            decoration: InputDecoration(
                              hintText:    'e.g. 3rd-year CSE student. Happy to help with DSA and databases.',
                              counterText: '${_bioCtrl.text.length}/$_maxBio',
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Bio is required.' : null,
                          ),
                        ),
                        const SizedBox(height: AppLayout.space16),

                        // Department
                        const _SectionLabel(label: 'Department'),
                        const SizedBox(height: AppLayout.space8),
                        TextFormField(
                          controller: _deptCtrl,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Computer Science',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Department is required.' : null,
                        ),
                        const SizedBox(height: AppLayout.space16),

                        // Year of study
                        const _SectionLabel(label: 'Year of study'),
                        const SizedBox(height: AppLayout.space8),
                        DropdownButtonFormField<int>(
                          initialValue: _yearOfStudy,
                          hint: const Text('Select year'),
                          items: List.generate(5, (i) => i + 1)
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text('Year $y'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _yearOfStudy = v),
                          validator: (v) => v == null ? 'Select your year of study.' : null,
                        ),
                        const SizedBox(height: AppLayout.space24),

                        // Subjects
                        _SectionLabel(
                          label: 'Subjects you teach',
                          hint: _selectedSubjectIds.isEmpty
                              ? 'Select at least one subject.'
                              : null,
                          hintIsError: _selectedSubjectIds.isEmpty && _serverError != null,
                        ),
                        const SizedBox(height: AppLayout.space8),
                        _SubjectChips(
                          allSubjects: _allSubjects,
                          selectedIds: _selectedSubjectIds,
                          onToggle: (id) => setState(() {
                            if (_selectedSubjectIds.contains(id)) {
                              _selectedSubjectIds.remove(id);
                            } else {
                              _selectedSubjectIds.add(id);
                            }
                          }),
                        ),
                        const SizedBox(height: AppLayout.space12),

                        // Add subject field
                        _AddSubjectField(
                          controller: _newSubjectCtrl,
                          loading:    _addingSubject,
                          error:      _addSubjectError,
                          onAdd:      _addSubject,
                        ),
                        const SizedBox(height: AppLayout.space32),

                        // Save
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.onPrimary))
                                : Text(_isNew ? 'Create profile' : 'Save changes'),
                          ),
                        ),
                        const SizedBox(height: AppLayout.space32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject chip grid
// ---------------------------------------------------------------------------
class _SubjectChips extends StatelessWidget {
  final List<Subject> allSubjects;
  final Set<int>      selectedIds;
  final void Function(int id) onToggle;

  const _SubjectChips({
    required this.allSubjects,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (allSubjects.isEmpty) {
      return Text('No subjects available.',
          style: tt.bodySmall?.copyWith(color: AppColors.muted));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: allSubjects.map((s) {
        final selected = selectedIds.contains(s.id);
        return GestureDetector(
          onTap: () => onToggle(s.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              s.name,
              style: tt.labelSmall?.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.ink,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Add subject inline field
// ---------------------------------------------------------------------------
class _AddSubjectField extends StatelessWidget {
  final TextEditingController controller;
  final bool                  loading;
  final String?               error;
  final VoidCallback          onAdd;

  const _AddSubjectField({
    required this.controller,
    required this.loading,
    required this.error,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onAdd(),
                decoration: const InputDecoration(
                  hintText: 'Add a new subject…',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: AppLayout.space8),
            OutlinedButton(
              onPressed: loading ? null : onAdd,
              child: loading
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : const Text('Add'),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: tt.bodySmall?.copyWith(color: AppColors.declined)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String  label;
  final String? hint;
  final bool    hintIsError;

  const _SectionLabel({
    required this.label, this.hint, this.hintIsError = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelLarge),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: tt.bodySmall?.copyWith(
              color: hintIsError ? AppColors.declined : AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.space12, vertical: AppLayout.space8),
      decoration: BoxDecoration(
        color: AppColors.declinedBg,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.declined.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 15, color: AppColors.declined),
        const SizedBox(width: AppLayout.space8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.declined),
          ),
        ),
      ]),
    );
  }
}
