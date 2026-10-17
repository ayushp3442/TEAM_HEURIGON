import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// ---------------------------------------------------------------------------
// PrivacyPolicyScreen — Real, plain-language privacy information at /privacy
// ---------------------------------------------------------------------------
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Title(
      title: 'Privacy Policy | $kAppName',
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
            'Privacy Policy',
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
                  Text('Privacy Policy', style: tt.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: October 2026',
                    style: tt.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppLayout.space24),
                  const Divider(height: 1),
                  const SizedBox(height: AppLayout.space24),

                  const _Section(
                    title: '1. Overview',
                    content:
                        '$kAppName is an academic peer tutoring platform designed for campus course learning. This privacy statement explains plainly and honestly what data we collect, how it is stored, and what your rights are.',
                  ),

                  const _Section(
                    title: '2. What Data We Store',
                    content:
                        'We only store data you explicitly provide during account registration and tutoring usage:\n'
                        '• Account details: your full name, email address, password hash, and role (Student or Tutor).\n'
                        '• Tutor profile: your self-written biography, department, year of study, and subjects taught.\n'
                        '• Tutoring activity: availability slots you post, session requests you submit or receive, and booking status.\n'
                        '• Direct messages: messages sent in the 24-hour post-session chat window.',
                  ),

                  const _Section(
                    title: '3. Local Storage and Cookies',
                    content:
                        'This application does NOT use advertising cookies, tracking scripts, or analytics cookies. '
                        'The only item saved on your device is an authentication token stored in your browser\'s local storage (shared_preferences), which is necessary to keep you securely signed in between visits.',
                  ),

                  const _Section(
                    title: '4. Message Privacy and Access',
                    content:
                        'Post-session chats are private and restricted strictly to the student and tutor participating in that accepted session. Chats automatically become read-only 24 hours after the scheduled session end time.',
                  ),

                  _Section(
                    title: '5. Data Deletion',
                    content: kContactEmail.isNotEmpty
                        ? 'You have the right to request the complete deletion of your account, tutor profile, requests, and message history. To request deletion, email us directly at $kContactEmail. We will remove your records from the database.'
                        : 'You have the right to request the complete deletion of your account, tutor profile, requests, and message history. When requested through the platform, your records are deleted from the database.',
                  ),

                  const _Section(
                    title: '6. Disclaimer',
                    content:
                        'This application is a student project created for an ACM Hackathon competition. This document is a plain-language summary of our data handling practices and does not constitute formal legal advice.',
                  ),

                  const SizedBox(height: AppLayout.space32),
                  const Divider(height: 1),
                  const SizedBox(height: AppLayout.space16),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => context.go('/terms'),
                        child: const Text('View Terms of Service'),
                      ),
                      const Spacer(),
                      if (kContactEmail.isNotEmpty)
                        Text(
                          'Contact: $kContactEmail',
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
