import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFF9FAFB),
              Color(0xFFEFF6FF),
            ],
            stops: [0, 0.5, 1],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative left panel (desktop only)
                if (MediaQuery.of(context).size.width > 900) ...[
                  _LeftPanel(),
                  const SizedBox(width: 60),
                ],
                _LoginCard(
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  rememberMe: _rememberMe,
                  onObscureToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onRememberToggle: (v) =>
                      setState(() => _rememberMe = v ?? false),
                  onLogin: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: DozColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'DOZ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'DOZ Taxi\nAdmin Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: DozColors.textPrimaryLight,
              height: 1.2,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage rides, drivers, payments, and everything else from one powerful control center.',
            style: TextStyle(
              fontSize: 15,
              color: DozColors.textMutedLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          ...[
            ('Real-time ride monitoring', Icons.directions_car),
            ('Driver management & approval', Icons.drive_eta),
            ('Revenue analytics & reports', Icons.bar_chart),
            ('Promo codes & promotions', Icons.local_offer),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: DozColors.primaryGreenSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.$2,
                        size: 16, color: DozColors.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DozColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onObscureToggle;
  final ValueChanged<bool?> onRememberToggle;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onObscureToggle,
    required this.onRememberToggle,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      width: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: DozColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOZ Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DozColors.textPrimaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: DozColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Error message
            if (auth.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: DozColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DozColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: DozColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.error!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: DozColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email field
            _FieldLabel('Email address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'admin@doz.taxi',
                prefixIcon: Icon(Icons.email_outlined, size: 18),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            _FieldLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onLogin(),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  onPressed: onObscureToggle,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: DozColors.textMutedLight,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Remember me
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: onRememberToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 13,
                    color: DozColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : onLogin,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                'DOZ Taxi Admin Panel v1.0',
                style: TextStyle(
                  fontSize: 11,
                  color: DozColors.textDisabledLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: DozColors.textSecondaryLight,
      ),
    );
  }
}
