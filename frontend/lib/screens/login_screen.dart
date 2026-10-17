import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../core/api_client.dart';
import '../widgets/brand_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool  _showPassword  = false;
  bool  _submitting    = false;
  String? _serverError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await context.read<AuthProvider>().login(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // go_router redirect will handle navigation after notifyListeners()
    } catch (e) {
      setState(() => _serverError = ApiClient.errorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppLayout.pagePadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App name
                Center(
                  child: StudyCircleLogo(
                    height: 54,
                    showText: true,
                    onTap: () => context.go('/'),
                  ),
                ),
                const SizedBox(height: AppLayout.space28),

                // Heading
                Text('Sign in', style: tt.displayMedium, textAlign: TextAlign.left),
                const SizedBox(height: AppLayout.space8),
                Text(
                  'Find a peer tutor for your next exam or assignment.',
                  style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppLayout.space24),

                // Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppTheme.borderRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(AppLayout.space24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Server error
                        if (_serverError != null) ...[
                          _ErrorBanner(message: _serverError!),
                          const SizedBox(height: AppLayout.space16),
                        ],

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.mail_outline, size: 18),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required.';
                            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                            if (!ok) return 'Enter a valid email address.';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppLayout.space16),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.muted,
                              ),
                              onPressed: () =>
                                  setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required.';
                            if (v.length < 6) return 'Password must be at least 6 characters.';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppLayout.space24),

                        // Submit
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppLayout.space16),

                // Link to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No account?', style: tt.bodyMedium?.copyWith(color: AppColors.muted)),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Create one'),
                    ),
                  ],
                ),
                const SizedBox(height: AppLayout.space16),

                // Legal footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => context.go('/privacy'),
                      child: Text('Privacy Policy', style: tt.labelSmall?.copyWith(color: AppColors.muted)),
                    ),
                    const SizedBox(width: AppLayout.space12),
                    Text('•', style: tt.labelSmall?.copyWith(color: AppColors.muted)),
                    const SizedBox(width: AppLayout.space12),
                    InkWell(
                      onTap: () => context.go('/terms'),
                      child: Text('Terms of Service', style: tt.labelSmall?.copyWith(color: AppColors.muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.declined),
          const SizedBox(width: AppLayout.space8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.declined,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
