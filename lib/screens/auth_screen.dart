import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: Stack(
        children: [
          // Top Left Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
                child: ClipOval(
                  child: Material(
                    color: context.colors.glass,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: context.colors.ink,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.colors.lineStrong,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.cardShadow.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/design/logo_landscape.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Innerscape',
                        style: InnerscapeText.heading(size: 38),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Your space, backed up.',
                        style: InnerscapeText.serifItalic(
                          size: 15.5,
                          color: context.colors.inkSoft,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connect your account to sync your journal securely across devices.',
                            style: InnerscapeText.serifItalic(
                              size: 15,
                              color: context.colors.inkSoft,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.colors.peachSoft.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.colors.peach.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
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

                          // Google Button
                          _SocialButton(
                            label: 'Continue with Google',
                            icon: Icons.g_mobiledata,
                            onPressed: auth.loading
                                ? null
                                : auth.signInWithGoogle,
                          ),
                          const SizedBox(height: 16),

                          // Apple Button
                          _SocialButton(
                            label: 'Continue with Apple',
                            icon: Icons.apple,
                            onPressed: auth.loading
                                ? null
                                : auth.signInWithApple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Keep Journaling Anonymously',
                          style: InnerscapeText.serifItalic(
                            size: 14,
                            color: context.colors.mauve,
                          ),
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
  final IconData icon;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.lineStrong),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: context.colors.ink, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: InnerscapeText.body(
                      weight: FontWeight.w600,
                      color: context.colors.ink,
                      size: 14,
                    ),
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
