import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_slider.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  final _winCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  double _moodValue = 0.5;
  double _ringHue = 0;
  bool _showToast = false;

  static const _captions = [
    'Take a breath before you write.',
    'Saved. Let it rest for tonight.',
    'One true thing, kept.',
    'Written and set down gently.',
  ];
  String _caption = _captions[0];

  late final AnimationController _toastCtrl;
  late final Animation<double> _toastAnim;

  @override
  void initState() {
    super.initState();
    _toastCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _toastAnim = CurvedAnimation(parent: _toastCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    _goalCtrl.dispose();
    _toastCtrl.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final rng = math.Random();
    setState(() {
      _ringHue = rng.nextDouble() * 60 - 30;
      _caption = _captions[1 + rng.nextInt(_captions.length - 1)];
      _showToast = true;
    });
    _toastCtrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _toastCtrl.reverse().then((_) {
          if (mounted) setState(() => _showToast = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InnerscapeColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, 0.8),
            radius: 1.2,
            colors: [Color(0xFFFFE9D6), InnerscapeColors.cream],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EVENING REFLECTION',
                                style: InnerscapeText.eyebrow(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Today\'s aura',
                                style: InnerscapeText.heading(size: 22),
                              ),
                            ],
                          ),
                          // Streak pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: InnerscapeColors.glassStrong,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AuraRing(size: AuraRingSize.xs),
                                const SizedBox(width: 6),
                                Text(
                                  '12 days',
                                  style: InnerscapeText.bodyInter(
                                    size: 12.5,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Aura Ring
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 6),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          child: AuraRing(
                            size: AuraRingSize.lg,
                            hueShift: _ringHue,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Caption
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            _caption,
                            key: ValueKey(_caption),
                            style: InnerscapeText.serifItalic(
                              size: 13.5,
                              color: InnerscapeColors.mauve,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Mood slider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                      child: MoodSlider(
                        value: _moodValue,
                        onChanged: (v) => setState(() => _moodValue = v),
                      ),
                    ),
                  ),

                  // Input fields
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's one win",
                              style: InnerscapeText.eyebrow(),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _winCtrl,
                              minLines: 2,
                              maxLines: 4,
                              style: InnerscapeText.serifItalic(size: 16.5),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'What went right today?',
                                hintStyle: InnerscapeText.serifItalic(
                                  size: 16.5,
                                  color: const Color(0xFFB3A6C2),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tomorrow's one goal",
                              style: InnerscapeText.eyebrow(),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _goalCtrl,
                              minLines: 2,
                              maxLines: 4,
                              style: InnerscapeText.serifItalic(size: 16.5),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "What's worth showing up for?",
                                hintStyle: InnerscapeText.serifItalic(
                                  size: 16.5,
                                  color: const Color(0xFFB3A6C2),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Save button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
                      child: _GradientButton(
                        label: "Save today's entry",
                        onTap: _save,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Toast notification
            if (_showToast)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _toastAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(_toastAnim),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: InnerscapeColors.ink,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D1E142D),
                              blurRadius: 26,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          'Saved for today ✓',
                          style: InnerscapeText.bodyInter(
                            size: 13,
                            weight: FontWeight.w500,
                            color: const Color(0xFFF4EEFB),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient CTA button ────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
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
              widget.label,
              style: InnerscapeText.bodyInter(
                size: 14.5,
                weight: FontWeight.w600,
                color: const Color(0xFF3A2C29),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
