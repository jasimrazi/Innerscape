import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final weekData = provider.weeklyFocusFatigue;
    final auraData = provider.weeklyAuraData;

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Velocity & Patterns',
                        style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                    const SizedBox(height: 2),
                    Text('Insights', style: InnerscapeText.heading(size: 22, color: context.colors.ink)),
                  ],
                ),
              ),

              // Streak card
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: GlassCard(
                  child: Column(
                    children: [
                      const AuraRing(size: AuraRingSize.md),
                      const SizedBox(height: 14),
                      Text(
                        '${provider.streak}',
                        style: InnerscapeText.heading(size: 28, color: context.colors.ink),
                      ),
                      const SizedBox(height: 2),
                      Text('Day streak', style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                    ],
                  ),
                ),
              ),

              // Stat row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text('${provider.longestStreak}',
                                style: InnerscapeText.heading(size: 22, color: context.colors.ink)),
                            const SizedBox(height: 4),
                            Text('Longest streak',
                                style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text('${provider.totalEntries}',
                                style: InnerscapeText.heading(size: 22, color: context.colors.ink)),
                            const SizedBox(height: 4),
                            Text('Total entries',
                                style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Focus vs Fatigue chart
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus vs. Fatigue',
                          style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                      const SizedBox(height: 4),
                      Text(
                        'This week',
                        style: InnerscapeText.body(
                          size: 11,
                          color: context.colors.mauve,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: _FocusFatiguePainter(
                            violet: context.colors.violet,
                            peach: context.colors.peach,
                            mauve: context.colors.mauve,
                            focus: weekData.focus,
                            fatigue: weekData.fatigue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Legend
                      Row(
                        children: [
                          _LegendDot(color: context.colors.violet,
                              label: 'Focus'),
                          const SizedBox(width: 16),
                          _LegendDot(color: context.colors.peach,
                              label: 'Fatigue'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly Insights card
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🔮', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text('Weekly Insights',
                              style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.weeklyInsightText,
                        style: InnerscapeText.serifItalic(
                          size: 15.5,
                          color: context.colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly aura grid
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This week's aura",
                          style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _WeekDay(label: 'M', hue: auraData[0].hue, active: auraData[0].active),
                          _WeekDay(label: 'T', hue: auraData[1].hue, active: auraData[1].active),
                          _WeekDay(label: 'W', hue: auraData[2].hue, active: auraData[2].active),
                          _WeekDay(label: 'T', hue: auraData[3].hue, active: auraData[3].active),
                          _WeekDay(label: 'F', hue: auraData[4].hue, active: auraData[4].active),
                          _WeekDay(label: 'S', hue: auraData[5].hue, active: auraData[5].active),
                          _WeekDay(label: 'S', hue: auraData[6].hue, active: auraData[6].active),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Week Day dot ───────────────────────────────────────────────────────────────
class _WeekDay extends StatelessWidget {
  final String label;
  final double hue;
  final bool active;
  const _WeekDay(
      {required this.label, required this.hue, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        active
            ? AuraRing(size: AuraRingSize.xs, hueShift: hue)
            : Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.lineStrong,
                    width: 1.5,
                  ),
                ),
              ),
        const SizedBox(height: 6),
        Text(
          label,
          style: InnerscapeText.body(
            size: 10,
            color: context.colors.mauve,
          ),
        ),
      ],
    );
  }
}

// ── Legend dot ─────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: InnerscapeText.body(
            size: 10.5,
            color: context.colors.mauve,
          ),
        ),
      ],
    );
  }
}

// ── Focus vs Fatigue chart painter ────────────────────────────────────────────
class _FocusFatiguePainter extends CustomPainter {
  final Color violet;
  final Color peach;
  final Color mauve;
  final List<double?> focus;
  final List<double?> fatigue;

  _FocusFatiguePainter({
    required this.violet,
    required this.peach,
    required this.mauve,
    required this.focus,
    required this.fatigue,
  });

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final n = focus.length;
    final step = w / (n - 1);

    // Draw smooth lines
    _drawLine(canvas, size, focus, violet, step, h);
    _drawLine(canvas, size, fatigue, peach, step, h);

    // Draw dots
    _drawDots(canvas, size, focus, violet, step, h);
    _drawDots(canvas, size, fatigue, peach, step, h);

    // Day labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final hasData = focus[i] != null;
      tp.text = TextSpan(
        text: _days[i],
        style: TextStyle(
          fontFamily: 'BricolageGrotesque',
          fontSize: 9,
          color: hasData ? mauve : mauve.withValues(alpha: 0.4),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(i * step - tp.width / 2, h - tp.height));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double?> data, Color color,
      double step, double h) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final chartH = h - 16; // reserve 16px for labels
    int lastDrawnIdx = -1;

    for (int i = 0; i < data.length; i++) {
      final val = data[i];
      if (val == null) continue;

      final x = i * step;
      final y = chartH * (1 - val);

      if (lastDrawnIdx == -1 || i != lastDrawnIdx + 1) {
        path.moveTo(x, y);
      } else {
        final prevX = lastDrawnIdx * step;
        final prevY = chartH * (1 - data[lastDrawnIdx]!);
        final cp1x = prevX + (x - prevX) / 2;
        final cp2x = x - (x - prevX) / 2;
        path.cubicTo(cp1x, prevY, cp2x, y, x, y);
      }
      lastDrawnIdx = i;
    }
    canvas.drawPath(path, paint);
  }

  void _drawDots(Canvas canvas, Size size, List<double?> data, Color color,
      double step, double h) {
    final paint = Paint()..color = color;
    final chartH = h - 16;
    for (int i = 0; i < data.length; i++) {
      final val = data[i];
      if (val == null) continue;
      canvas.drawCircle(
        Offset(i * step, chartH * (1 - val)),
        3.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FocusFatiguePainter oldDelegate) {
    return oldDelegate.focus != focus ||
        oldDelegate.fatigue != fatigue ||
        oldDelegate.violet != violet ||
        oldDelegate.peach != peach ||
        oldDelegate.mauve != mauve;
  }
}

