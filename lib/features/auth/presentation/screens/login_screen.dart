import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/design_system/components/portal_button.dart';
import '../../../../core/design_system/components/portal_card.dart';
import '../../../../core/design_system/components/portal_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Secure Login Screen supporting email credentials and one-tap demo accounts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _fillDemoCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(RouteConstants.root);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthFailureState ? state.message : null;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxFormWidth,
                ),
                child: PortalCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Branding Header
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.darkCardGradient
                                  : AppColors.primaryGradient,
                              borderRadius: AppSpacing.roundedLg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sign in to access your courses, materials, and academic progress.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Error Banner
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.roundedMd,
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Quick Demo Account Helpers
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm + 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.lightSurfaceAlt,
                            borderRadius: AppSpacing.roundedMd,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUICK DEMO SHORTCUTS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppSpacing.roundedSm,
                                        ),
                                      ),
                                      onPressed: () => _fillDemoCredentials(
                                        'instructor@academic.edu',
                                        'Teacher123!',
                                      ),
                                      icon: const Icon(Icons.psychology_outlined,
                                          size: 14),
                                      label: const Text('Instructor',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppSpacing.roundedSm,
                                        ),
                                      ),
                                      onPressed: () => _fillDemoCredentials(
                                        'student@academic.edu',
                                        'Student123!',
                                      ),
                                      icon: const Icon(Icons.school_outlined,
                                          size: 14),
                                      label: const Text('Student',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Form Inputs
                        PortalTextField(
                          label: 'Academic Email Address',
                          hintText: 'e.g. name@university.edu',
                          prefixIcon: Icons.alternate_email_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address.';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PortalTextField(
                          label: 'Password',
                          hintText: 'Enter your account password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: _passwordController,
                          onSubmitted: (_) => _submitLogin(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Submit Button
                        PortalButton(
                          label: 'Sign In to Portal',
                          isFullWidth: true,
                          isLoading: isLoading,
                          onPressed: _submitLogin,
                          icon: Icons.login_rounded,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(RouteConstants.register),
                              child: const Text(
                                'Register Now',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
        },
      ),
    );
  }
}
