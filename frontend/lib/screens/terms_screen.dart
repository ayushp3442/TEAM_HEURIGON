import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// ---------------------------------------------------------------------------
// TermsOfServiceScreen — Real, plain-language terms at /terms
// ---------------------------------------------------------------------------
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Title(
      title: 'Terms of Service | $kAppName',
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(
            'Terms of Service',
            style: tt.headlineMedium?.copyWith(color: AppColors.ink),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.space24,
            vertical: AppLayout.space32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terms of Service', style: tt.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: October 2026',
                    style: tt.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppLayout.space24),
                  const Divider(height: 1),
                  const SizedBox(height: AppLayout.space24),

                  const _Section(
                    title: '1. Acceptance of Terms',
                    content:
                        'By creating an account or using $kAppName, you agree to these Terms. If you do not agree, please do not use the application.',
                  ),

                  const _Section(
                    title: '2. Purpose and Academic Integrity',
                    content:
                        '$kAppName facilitates peer-led academic assistance, conceptual clarifications, and doubt solving for campus courses. '
                        'Users must uphold campus academic integrity guidelines. Tutoring sessions and chat messages must not be used to complete exams, plagiarize graded work, or violate university honor codes.',
                  ),

                  const _Section(
                    title: '3. Tutor and Student Responsibilities',
                    content:
                        '• Tutors agree to post accurate availability slots and fulfill accepted bookings responsibly.\n'
                        '• Students agree to arrive promptly for scheduled sessions (whether online or at on-campus locations) and submit respectful, constructive session requests.\n'
                        '• Both parties agree to communicate respectfully during sessions and in the 24-hour post-session messaging window.',
                  ),

                  const _Section(
                    title: '4. Booking and Cancellation Policy',
                    content:
                        'Students may cancel pending session requests prior to acceptance by the tutor. Once a session is accepted, conflicting requests for the same slot are automatically declined to maintain scheduling fairness.',
                  ),

                  const _Section(
                    title: '5. Student Hackathon Project Disclaimer',
                    content:
                        'This application is provided "as is" as an academic hackathon project. The creators make no warranties regarding uninterrupted availability. This document does not constitute legal counsel.',
                  ),

                  const SizedBox(height: AppLayout.space32),
                  const Divider(height: 1),
                  const SizedBox(height: AppLayout.space16),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go('/privacy'),
                        child: const Text('View Privacy Policy'),
                      ),
                      const Spacer(),
                      if (kContactEmail.isNotEmpty)
                        Text(
                          'Questions? $kContactEmail',
                          style: tt.bodySmall?.copyWith(color: AppColors.muted),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.headlineSmall),
          const SizedBox(height: 6),
          Text(
            content,
            style: tt.bodyMedium?.copyWith(height: 1.6, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
