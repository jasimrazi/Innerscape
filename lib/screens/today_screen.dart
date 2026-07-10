import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import '../widgets/mood_slider.dart';
import '../providers/journal_provider.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with TickerProviderStateMixin {
  final _winCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  bool _showToast = false;

  late final AnimationController _toastCtrl;
  late final Animation<double> _toastAnim;

  // Breathing Guide State
  bool _isBreathing = false;
  String _breathingText = 'Hold to breathe';

  late final AnimationController _breathingCtrl;
  late final Animation<double> _breathingScaleAnim;

  @override
  void initState() {
    super.initState();
    _toastCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _toastAnim = CurvedAnimation(parent: _toastCtrl, curve: Curves.easeOut);

    // 4 seconds to inhale, 4 seconds to exhale
    _breathingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathingScaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _breathingCtrl, curve: Curves.easeInOutSine),
    );

    _breathingCtrl.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() {
          _breathingText = 'Breathe in...';
        });
        HapticFeedback.selectionClick();
      } else if (status == AnimationStatus.reverse) {
        setState(() {
          _breathingText = 'Breathe out...';
        });
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _winCtrl.dispose();
    _goalCtrl.dispose();
    _toastCtrl.dispose();
    _breathingCtrl.dispose();
    super.dispose();
  }

  void _startBreathing() {
    HapticFeedback.selectionClick();
    setState(() {
      _isBreathing = true;
      _breathingText = 'Breathe in...';
    });
    _breathingCtrl.repeat(reverse: true);
  }

  void _stopBreathing() {
    if (!_isBreathing) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isBreathing = false;
      _breathingText = 'Hold to breathe';
    });
    // Smoothly shrink back to normal scale
    _breathingCtrl.animateTo(
      0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final provider = context.read<JournalProvider>();
    provider.saveEntry(_winCtrl.text, _goalCtrl.text);
    _winCtrl.clear();
    _goalCtrl.clear();
    provider.setMoodValue(0.5);

    setState(() {
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
    final provider = context.watch<JournalProvider>();
    return Scaffold(
      backgroundColor: InnerscapeColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, 0.8),
            radius: 1.2,
            colors: [InnerscapeColors.warmPeach, InnerscapeColors.cream],
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
                                  '${provider.streak} days',
                                  style: InnerscapeText.body(
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
                        child: ScaleTransition(
                          scale: _breathingScaleAnim,
                          child: GestureDetector(
                            onTapDown: (_) => _startBreathing(),
                            onTapUp: (_) => _stopBreathing(),
                            onTapCancel: () => _stopBreathing(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                              child: AuraRing(
                                size: AuraRingSize.lg,
                                hueShift: provider.ringHue,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Column(
                                    key: ValueKey(_isBreathing ? _breathingText : 'idle'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isBreathing ? _breathingText : 'Hold to breathe',
                                        style: InnerscapeText.serifItalic(
                                          size: 15,
                                          color: _isBreathing
                                              ? InnerscapeColors.ink
                                              : InnerscapeColors.mauve,
                                        ),
                                      ),
                                      if (!_isBreathing) ...[
                                        const SizedBox(height: 8),
                                        Icon(
                                          Icons.spa_outlined,
                                          color: InnerscapeColors.mauve
                                              .withValues(alpha: 0.5),
                                          size: 18,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                            provider.caption,
                            key: ValueKey(provider.caption),
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
                        value: provider.moodValue,
                        onChanged: (v) => provider.setMoodValue(v),
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
                                  color: InnerscapeColors.hint,
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
                                  color: InnerscapeColors.hint,
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
                              color: InnerscapeColors.toastShadow,
                              blurRadius: 26,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          'Saved for today ✓',
                          style: InnerscapeText.body(
                            size: 13,
                            weight: FontWeight.w500,
                            color: InnerscapeColors.toastText,
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
              style: InnerscapeText.body(
                size: 14.5,
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
