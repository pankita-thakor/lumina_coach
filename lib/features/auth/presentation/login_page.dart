import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _awaitingVerification = false;
  String _pendingEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (!_isLogin && password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _busy = true);
    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'io.supabase.luminacoach://login-callback/',
        );
        if (mounted) {
          // If identities is empty, the email is already registered
          if (response.user != null && (response.user!.identities?.isEmpty ?? false)) {
            _showError('An account with this email already exists. Please sign in.');
          } else {
            setState(() {
              _awaitingVerification = true;
              _pendingEmail = email;
            });
          }
        }
      }
    } on AuthException catch (e) {
      final details = [
        if ((e.statusCode ?? '').isNotEmpty) 'status=${e.statusCode}',
        if ((e.code ?? '').isNotEmpty) 'code=${e.code}',
      ].join(' ');
      debugPrint('Supabase auth error: ${e.message} $details');
      _showError(
        details.isEmpty ? e.message : '${e.message} ($details)',
      );
    } catch (e) {
      _showError('An unexpected error occurred');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_pendingEmail.isEmpty) return;
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: _pendingEmail,
        emailRedirectTo: 'io.supabase.luminacoach://login-callback/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent! Check your inbox and spam folder.')),
        );
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to resend email. Try again later.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _oauth(OAuthProvider provider) async {
    if (!AppConfig.isSupabaseConfigured) {
      if (mounted) context.go('/setup');
      return;
    }
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.luminacoach://login-callback/',
      );
    } catch (e) {
      _showError('Sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (_awaitingVerification) {
      return _VerifyEmailScreen(
        email: _pendingEmail,
        busy: _busy,
        onResend: _resendVerificationEmail,
        onBackToLogin: () => setState(() {
          _awaitingVerification = false;
          _isLogin = true;
        }),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: theme.brightness == Brightness.dark
                    ? AppPalette.heroGradientDark
                    : AppPalette.heroGradientLight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.xl),
                    // Logo Icon
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 40,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                    Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _isLogin
                          ? 'Continue your journey to communication mastery'
                          : 'Start your journey to communication mastery',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl * 1.5),
                    
                    // Form fields
                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: Spacing.md),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                    if (!_isLogin) ...[
                      const SizedBox(height: Spacing.md),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                      ),
                    ],
                    
                    const SizedBox(height: Spacing.lg),
                    AppPrimaryButton(
                      label: _isLogin ? 'Sign In' : 'Create Account',
                      busy: _busy,
                      onPressed: _submit,
                    ),
                    
                    const SizedBox(height: Spacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: theme.textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin ? 'Sign Up' : 'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: Spacing.xl),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: Spacing.xl),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            onPressed: _busy ? null : () => _oauth(OAuthProvider.google),
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: _SocialButton(
                            onPressed: _busy ? null : () => _oauth(OAuthProvider.apple),
                            icon: Icons.apple,
                            label: 'Apple',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: Spacing.xl * 2),
                    Text(
                      'By signing in, you agree to our Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyEmailScreen extends StatelessWidget {
  const _VerifyEmailScreen({
    required this.email,
    required this.busy,
    required this.onResend,
    required this.onBackToLogin,
  });

  final String email;
  final bool busy;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 72, color: scheme.primary),
              const SizedBox(height: Spacing.xl),
              Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'We sent a confirmation link to:\n$email\n\nOpen it to activate your account. Also check your spam/junk folder.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Spacing.xl * 1.5),
              AppPrimaryButton(
                label: busy ? 'Sending...' : 'Resend Verification Email',
                busy: busy,
                onPressed: onResend,
              ),
              const SizedBox(height: Spacing.md),
              TextButton(
                onPressed: onBackToLogin,
                child: Text(
                  'Back to Sign In',
                  style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
