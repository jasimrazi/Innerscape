import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import '../models/journal_entry.dart';

class DetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InnerscapeColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.6),
            radius: 1.0,
            colors: [Color(0xFFF3E9FF), InnerscapeColors.cream],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: InnerscapeColors.lineStrong,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '← Back',
                          style: InnerscapeText.bodyInter(
                            size: 12.5,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
                  child: Column(
                    children: [
                      AuraRing(
                        size: AuraRingSize.md,
                        hueShift: entry.hueShift,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        entry.date,
                        style: InnerscapeText.eyebrow(),
                      ),
                      const SizedBox(height: 18),

                      // Win card
                      GlassCard(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('The win', style: InnerscapeText.eyebrow()),
                            const SizedBox(height: 8),
                            Text(
                              entry.win,
                              style: InnerscapeText.serifItalic(
                                size: 17,
                                color: InnerscapeColors.ink,
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
                              style: InnerscapeText.eyebrow(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.goal,
                              style: InnerscapeText.serifItalic(
                                size: 17,
                                color: InnerscapeColors.ink,
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
