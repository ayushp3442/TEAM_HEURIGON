import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../widgets/brand_logo.dart';

class FallbackVerticalStory extends StatelessWidget {
  const FallbackVerticalStory({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.space20,
        vertical: AppLayout.space24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scene 0: Hero
              const StudyCircleLogo(height: 44, showText: true),
              const SizedBox(height: AppLayout.space20),
              Text(
                'Stuck on a doubt? Ask a senior who solved it last year.',
                style: tt.displayLarge?.copyWith(fontSize: 30, height: 1.25),
              ),
              const SizedBox(height: AppLayout.space12),
              Text(
                'StudyCircle connects first-year students with senior students from their own college. Pick a subject, choose a time that works, and get your doubt cleared.',
                style: tt.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppLayout.space24),
              Wrap(
                spacing: AppLayout.space12,
                runSpacing: AppLayout.space12,
                children: [
                  FilledButton(
                    onPressed: () => context.go('/register?role=student'),
                    child: const Text('Find a senior tutor'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/register?role=tutor'),
                    child: const Text('Become a tutor'),
                  ),
                ],
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 1: The doubt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                  border: Border.all(color: AppColors.accent, width: AppLayout.borderWidth1),
                ),
                child: Text(
                  '11:40 PM • Chapter 4, question 7',
                  style: tt.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppLayout.space12),
              Text(
                '11:40 PM. Chapter 4, question 7. Nothing in your textbook explains it.',
                style: tt.headlineMedium?.copyWith(height: 1.3),
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 2: The search
              Text(
                'So you search online. Hours of videos. Too long, wrong syllabus, a different problem, and nobody to reply to your comment.',
                style: tt.headlineMedium?.copyWith(height: 1.3),
              ),
              const SizedBox(height: AppLayout.space16),
              const Wrap(
                spacing: AppLayout.space8,
                runSpacing: AppLayout.space8,
                children: [
                  _TagChip('Too advanced'),
                  _TagChip('Wrong syllabus'),
                  _TagChip('A different problem'),
                  _TagChip('2 hours long'),
                  _TagChip('No reply to comments'),
                ],
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 3: Still stuck
              Text(
                'You still have the doubt, and the test is close.',
                style: tt.headlineMedium?.copyWith(height: 1.3),
              ),
              const SizedBox(height: AppLayout.space8),
              Text(
                'Generic internet videos cannot replace a peer who sat in the same lecture hall.',
                style: tt.bodyMedium?.copyWith(color: AppColors.muted),
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 4: A senior
              Text(
                'A senior in your college has already solved this kind of problem. They are listed here with their subjects and free time slots.',
                style: tt.headlineMedium?.copyWith(height: 1.3),
              ),
              const SizedBox(height: AppLayout.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppLayout.space20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                  border: Border.all(color: AppColors.primary, width: AppLayout.borderWidth1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.school_outlined, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppLayout.space12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120, height: 10, color: AppColors.ink.withValues(alpha: 0.7)),
                            const SizedBox(height: 4),
                            Container(width: 160, height: 8, color: AppColors.muted.withValues(alpha: 0.3)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.space16),
                    const Wrap(
                      spacing: AppLayout.space8,
                      runSpacing: AppLayout.space8,
                      children: [
                        _TagChip('Subjects'),
                        _TagChip('Free time slots'),
                        _TagChip('Online or on campus'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 5: How it works
              Text('How it works', style: tt.displaySmall),
              const SizedBox(height: AppLayout.space16),
              const _StepRow(number: '1', text: 'Search by subject, mode, and date.'),
              const SizedBox(height: AppLayout.space12),
              const _StepRow(number: '2', text: 'Request a slot with a short message.'),
              const SizedBox(height: AppLayout.space12),
              const _StepRow(number: '3', text: 'Meet online or on campus.'),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 6: Chat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat for 24 hours',
                    style: tt.displaySmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppLayout.radius6),
                      border: Border.all(color: AppColors.accent, width: AppLayout.borderWidth1),
                    ),
                    child: Text(
                      '24h 00m left',
                      style: tt.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.space12),
              Text(
                'After the session, the chat stays open for 24 hours. Ask the follow-up questions you only think of later.',
                style: tt.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppLayout.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppLayout.space16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppLayout.radius6),
                  border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppLayout.radius6),
                        ),
                        child: Text(
                          'Why does BFS use a queue instead of a stack?',
                          style: tt.bodySmall?.copyWith(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppLayout.space10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 340),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppLayout.radius6),
                          border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
                        ),
                        child: Text(
                          'BFS explores level by level. FIFO queue guarantees you finish level k before touching level k+1.',
                          style: tt.bodySmall?.copyWith(color: AppColors.ink, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppLayout.space32),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space32),

              // Scene 7: CTA & Footer
              Text(
                'Next time you get stuck, ask a senior.',
                style: tt.headlineMedium,
              ),
              const SizedBox(height: AppLayout.space8),
              Text(
                'Know this subject well? Post your free slots and help the juniors.',
                style: tt.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppLayout.space24),
              Wrap(
                spacing: AppLayout.space12,
                runSpacing: AppLayout.space12,
                children: [
                  FilledButton(
                    onPressed: () => context.go('/register?role=student'),
                    child: const Text('Find a senior tutor'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/register?role=tutor'),
                    child: const Text('Become a tutor'),
                  ),
                ],
              ),

              const SizedBox(height: AppLayout.space40),
              const Divider(height: 1),
              const SizedBox(height: AppLayout.space20),

              Wrap(
                spacing: AppLayout.space16,
                runSpacing: AppLayout.space10,
                children: [
                  Text(kAppName, style: tt.labelSmall?.copyWith(color: AppColors.muted)),
                  InkWell(
                    onTap: () => context.go('/privacy'),
                    child: Text('Privacy Policy', style: tt.labelSmall),
                  ),
                  InkWell(
                    onTap: () => context.go('/terms'),
                    child: Text('Terms of Service', style: tt.labelSmall),
                  ),
                  if (kContactEmail.isNotEmpty)
                    Text(kContactEmail, style: tt.labelSmall?.copyWith(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: AppLayout.space32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppLayout.radius6),
        border: Border.all(color: AppColors.border, width: AppLayout.borderWidth1),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppLayout.radius6),
          ),
          alignment: Alignment.center,
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: AppLayout.space12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
