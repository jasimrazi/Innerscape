import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import '../models/journal_entry.dart';

String _moodEmoji(double value) {
  final index = (value * 4).round().clamp(0, 4);
  return const ['😔', '😐', '😌', '😊', '✨'][index];
}

String _moodLabel(double value) {
  final index = (value * 4).round().clamp(0, 4);
  return const ['Drained', 'Mellow', 'Calm', 'Bright', 'Radiant'][index];
}

class DetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.6),
            radius: 1.0,
            colors: [context.colors.lavender, context.colors.cream],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _TapFeedback(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.colors.lineStrong,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '← Back',
                          style: InnerscapeText.body(
                            size: 12.5,
                            weight: FontWeight.w500,
                            color: context.colors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      AuraRing(
                        size: AuraRingSize.md,
                        hueShift: entry.hueShift,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.date,
                        style: InnerscapeText.eyebrow(color: context.colors.mauve),
                      ),
                      const SizedBox(height: 12),
                      // Mood indicator
                      Text(
                        _moodEmoji(entry.moodValue),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moodLabel(entry.moodValue),
                        style: InnerscapeText.body(
                          size: 11,
                          color: context.colors.mauve,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Win card
                      GlassCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('The win', style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                            const SizedBox(height: 8),
                            Text(
                              entry.win,
                              style: InnerscapeText.serifItalic(
                                size: 17,
                                color: context.colors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Goal card
                      GlassCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The goal, the day after',
                              style: InnerscapeText.eyebrow(color: context.colors.mauve),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.goal,
                              style: InnerscapeText.serifItalic(
                                size: 17,
                                color: context.colors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _TapFeedback extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TapFeedback({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final pressed = ValueNotifier<bool>(false);
    return GestureDetector(
      onTapDown: (_) => pressed.value = true,
      onTapUp: (_) {
        pressed.value = false;
        onTap();
      },
      onTapCancel: () => pressed.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: pressed,
        builder: (context, isPressed, child) {
          return AnimatedOpacity(
            opacity: isPressed ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}
