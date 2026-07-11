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

  late final AnimationController _toastCtrl;
  late final Animation<double> _toastAnim;

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
      final p = context.read<JournalProvider>();
      if (status == AnimationStatus.forward) {
        p.setBreathingText('Breathe in...');
        HapticFeedback.selectionClick();
      } else if (status == AnimationStatus.reverse) {
        p.setBreathingText('Breathe out...');
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
    final p = context.read<JournalProvider>();
    p.setBreathing(true);
    p.setBreathingText('Breathe in...');
    _breathingCtrl.repeat(reverse: true);
  }

  void _stopBreathing() {
    final p = context.read<JournalProvider>();
    if (!p.isBreathing) return;
    HapticFeedback.selectionClick();
    p.setBreathing(false);
    p.setBreathingText('Hold to breathe');
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
    final saved = provider.saveEntry(_winCtrl.text, _goalCtrl.text);

    if (!saved) {
      // Entry was empty — don't clear or show toast
      HapticFeedback.heavyImpact();
      return;
    }

    _winCtrl.clear();
    _goalCtrl.clear();
    provider.setMoodValue(0.5);

    provider.setShowToast(true);
    _toastCtrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _toastCtrl.reverse().then((_) {
          if (mounted) {
            context.read<JournalProvider>().setShowToast(false);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    return Scaffold(
      backgroundColor: context.colors.cream,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, 0.8),
            radius: 1.2,
            colors: [context.colors.warmPeach, context.colors.cream],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
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
                              color: context.colors.glassStrong,
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
                                    key: ValueKey(provider.isBreathing ? provider.breathingText : 'idle'),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        provider.isBreathing ? provider.breathingText : 'Hold to breathe',
                                        style: InnerscapeText.serifItalic(
                                          size: 15,
                                          color: provider.isBreathing
                                              ? context.colors.ink
                                              : context.colors.mauve,
                                        ),
                                      ),
                                      if (!provider.isBreathing) ...[
                                        const SizedBox(height: 8),
                                        Icon(
                                          Icons.spa_outlined,
                                          color: context.colors.mauve
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
                              color: context.colors.mauve,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Mood slider
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: MoodSlider(
                        value: provider.moodValue,
                        onChanged: (v) => provider.setMoodValue(v),
                      ),
                    ),
                  ),

                  // Input fields
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
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
                                  color: context.colors.hint,
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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
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
                                  color: context.colors.hint,
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
                      padding: EdgeInsets.fromLTRB(24, 4, 24, 32 + MediaQuery.of(context).viewInsets.bottom),
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
             if (provider.showToast)
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
                          color: context.colors.ink,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [ BoxShadow(
                              color: context.colors.toastShadow,
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
                            color: context.colors.toastText,
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.colors.violet, context.colors.peach],
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.violet.withValues(alpha: 0.40),
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
                color: context.colors.brown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
