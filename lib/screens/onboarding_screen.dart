import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _begin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.8),
            radius: 1.2,
            colors: [InnerscapeColors.lavender, InnerscapeColors.cream],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // Top spacer
                const Spacer(),

                // Aura Ring
                const AuraRing(size: AuraRingSize.lg),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Innerscape',
                  style: InnerscapeText.headingItalic(size: 34),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: Text(
                    'A breath each evening.\nOne win behind you, one goal ahead.',
                    textAlign: TextAlign.center,
                    style: InnerscapeText.serifItalic(
                      size: 16.5,
                      color: InnerscapeColors.inkSoft,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: _BeginButton(onTap: _begin),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Text(
                    'Takes less than a minute a day',
                    style: InnerscapeText.body(
                      size: 11.5,
                      color: InnerscapeColors.mauve,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BeginButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BeginButton({required this.onTap});

  @override
  State<_BeginButton> createState() => _BeginButtonState();
}

class _BeginButtonState extends State<_BeginButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [InnerscapeColors.violet, InnerscapeColors.peach],
            ),
            boxShadow: [
              BoxShadow(
                color: InnerscapeColors.violet.withValues(alpha: 0.40),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Begin',
              style: InnerscapeText.body(
                size: 15,
                weight: FontWeight.w600,
                color: InnerscapeColors.brown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
