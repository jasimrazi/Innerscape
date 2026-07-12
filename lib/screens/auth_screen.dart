import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/aura_ring.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: InnerscapeText.body(color: context.colors.toastText),
          ),
          backgroundColor: context.colors.ink,
        ),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      success = await auth.signUpWithEmail(email, password);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification email sent. Please check your inbox.',
              style: InnerscapeText.body(color: context.colors.toastText),
            ),
            backgroundColor: context.colors.ink,
          ),
        );
      }
    } else {
      success = await auth.signInWithEmail(email, password);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: Stack(
        children: [
          // Slow pulsing atmospheric background orb
          Positioned(
            top: 40,
            left: -40,
            child: AuraRing(size: AuraRingSize.lg),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Innerscape',
                        style: InnerscapeText.heading(size: 38),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        _isSignUp ? 'Create a space for your thoughts' : 'Welcome back to your space',
                        style: InnerscapeText.serifItalic(
                          size: 15.5,
                          color: context.colors.inkSoft,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _isSignUp = false);
                                    auth.clearError();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: !_isSignUp ? context.colors.violet : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign In',
                                        style: InnerscapeText.body(
                                          weight: !_isSignUp ? FontWeight.w600 : FontWeight.w400,
                                          color: !_isSignUp ? context.colors.ink : context.colors.mauve,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _isSignUp = true);
                                    auth.clearError();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _isSignUp ? context.colors.violet : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign Up',
                                        style: InnerscapeText.body(
                                          weight: _isSignUp ? FontWeight.w600 : FontWeight.w400,
                                          color: _isSignUp ? context.colors.ink : context.colors.mauve,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.colors.peachSoft.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: context.colors.peach.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                auth.errorMessage!,
                                style: InnerscapeText.body(
                                  size: 12,
                                  color: context.colors.peach,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Email Input
                          Text(
                            'Email Address',
                            style: InnerscapeText.body(
                              size: 11,
                              color: context.colors.mauve,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: InnerscapeText.body(color: context.colors.ink),
                            decoration: InputDecoration(
                              hintText: 'name@example.com',
                              hintStyle: InnerscapeText.body(color: context.colors.hint),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.colors.line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.colors.violet),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Input
                          Text(
                            'Password',
                            style: InnerscapeText.body(
                              size: 11,
                              color: context.colors.mauve,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: InnerscapeText.body(color: context.colors.ink),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: InnerscapeText.body(color: context.colors.hint),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.colors.line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.colors.violet),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          ElevatedButton(
                            onPressed: auth.loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.violet,
                              disabledBackgroundColor: context.colors.violet.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: auth.loading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colors.cream,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: InnerscapeText.body(
                                      weight: FontWeight.w600,
                                      color: context.colors.cream,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Sign-in Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.colors.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: InnerscapeText.body(
                              size: 11,
                              color: context.colors.mauve,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: context.colors.line)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Social Sign-in Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            label: 'Google',
                            iconPath: 'assets/google.png', // Fallback to label if assets missing
                            onPressed: auth.loading ? null : auth.signInWithGoogle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SocialButton(
                            label: 'Apple',
                            iconPath: 'assets/apple.png',
                            onPressed: auth.loading ? null : auth.signInWithApple,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Keep Journaling Anonymously',
                        style: InnerscapeText.serifItalic(
                          size: 14,
                          color: context.colors.mauve,
                        ),
                      ),
                    ),
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

class _SocialButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.iconPath,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Safe fallback icon
            Icon(
              label == 'Google' ? Icons.g_mobiledata : Icons.apple,
              color: context.colors.ink,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: InnerscapeText.body(
                weight: FontWeight.w600,
                color: context.colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
