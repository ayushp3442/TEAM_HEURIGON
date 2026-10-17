import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// LandingScreen — Public home at /
// Headline, concise explanation, "Find a tutor" + "Become a tutor" above fold,
// vertical 3-step "How it works" list, and plain footer.
// ---------------------------------------------------------------------------
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Title(
      title: 'Peer Tutoring Board | Verified Campus Course Assistance',
      color: AppColors.primary,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: AppColors.transparent,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
          title: Text(
            'Peer Tutoring Board',
            style: tt.headlineMedium?.copyWith(color: AppColors.ink),
          ),
          actions: [
            if (auth.isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(right: AppLayout.space16),
                child: FilledButton(
                  onPressed: () => context.go(auth.isTutor ? '/dashboard' : '/browse'),
                  child: Text(auth.isTutor ? 'Go to Dashboard' : 'Browse Tutors'),
                ),
              )
            else ...[
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Log in'),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppLayout.space16, left: AppLayout.space8),
                child: FilledButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Get started'),
                ),
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.space24,
                  vertical: AppLayout.space40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Above the fold
                    Text(
                      'One-on-one course tutoring from peers who already aced the class.',
                      style: tt.displayLarge?.copyWith(
                        fontSize: 32,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppLayout.space16),
                    Text(
                      'Book verified student tutors for on-campus or online sessions, with 24-hour post-session messaging for follow-up doubts.',
                      style: tt.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppLayout.space32),

                    // Primary CTAs
                    Wrap(
                      spacing: AppLayout.space12,
                      runSpacing: AppLayout.space12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context.go(auth.isLoggedIn ? '/browse' : '/register'),
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Find a tutor'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go(auth.isLoggedIn ? (auth.isTutor ? '/dashboard' : '/browse') : '/register'),
                          icon: const Icon(Icons.school_outlined, size: 18),
                          label: const Text('Become a tutor'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppLayout.space48),
                    const Divider(height: 1),
                    const SizedBox(height: AppLayout.space40),

                    // "How it works" — Vertical numbered list (Rule: NOT three cards in a row)
                    Text('How it works', style: tt.displayMedium),
                    const SizedBox(height: AppLayout.space8),
                    Text(
                      'A transparent, zero-friction process built specifically for collegiate academic assistance.',
                      style: tt.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: AppLayout.space24),

                    const _StepItem(
                      number: '1',
                      title: 'Browse subjects and available time slots',
                      description:
                          'Filter by subject, date, and preferred session mode (Online via video link or On-campus room locations). View verified tutor profiles with their department, year of study, and subject specialties.',
                    ),
                    const SizedBox(height: AppLayout.space16),

                    const _StepItem(
                      number: '2',
                      title: 'Request a session with a short note',
                      description:
                          'Select an open slot and write a short description of what topics or assignment problems you need help with. The tutor reviews and accepts your request.',
                    ),
                    const SizedBox(height: AppLayout.space16),

                    const _StepItem(
                      number: '3',
                      title: 'Attend your session and resolve follow-up doubts',
                      description:
                          'Meet online or on campus. After the session concludes, a post-session chat window opens automatically for 24 hours so you can ask lingering questions and exchange notes before it becomes read-only.',
                    ),

                    const SizedBox(height: AppLayout.space48),
                    const Divider(height: 1),
                    const SizedBox(height: AppLayout.space24),

                    // Footer (responsive across all screen widths)
                    Wrap(
                      spacing: AppLayout.space16,
                      runSpacing: AppLayout.space12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          'Peer Tutoring Board',
                          style: tt.labelSmall?.copyWith(color: AppColors.muted),
                        ),
                        InkWell(
                          onTap: () => context.go('/privacy'),
                          child: Text('Privacy Policy', style: tt.labelSmall),
                        ),
                        InkWell(
                          onTap: () => context.go('/terms'),
                          child: Text('Terms of Service', style: tt.labelSmall),
                        ),
                        Text(
                          kContactEmail,
                          style: tt.labelSmall?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.space16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical Numbered Step
// ---------------------------------------------------------------------------
class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppLayout.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTheme.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: AppLayout.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
