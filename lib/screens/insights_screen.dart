import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InnerscapeColors.cream,
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
                        style: InnerscapeText.eyebrow()),
                    const SizedBox(height: 2),
                    Text('Insights', style: InnerscapeText.heading(size: 22)),
                  ],
                ),
              ),

              // Streak card
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: GlassCard(
                  child: Column(
                    children: [
                      const AuraRing(size: AuraRingSize.md),
                      const SizedBox(height: 14),
                      Text(
                        '12',
                        style: InnerscapeText.heading(size: 28),
                      ),
                      const SizedBox(height: 2),
                      Text('Day streak', style: InnerscapeText.eyebrow()),
                    ],
                  ),
                ),
              ),

              // Stat row
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text('31',
                                style: InnerscapeText.heading(size: 22)),
                            const SizedBox(height: 4),
                            Text('Longest streak',
                                style: InnerscapeText.eyebrow()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        child: Column(
                          children: [
                            Text('146',
                                style: InnerscapeText.heading(size: 22)),
                            const SizedBox(height: 4),
                            Text('Total entries',
                                style: InnerscapeText.eyebrow()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Focus vs Fatigue chart
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus vs. Fatigue',
                          style: InnerscapeText.eyebrow()),
                      const SizedBox(height: 4),
                      Text(
                        'This week',
                        style: InnerscapeText.body(
                          size: 11,
                          color: InnerscapeColors.mauve,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: _FocusFatiguePainter(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Legend
                      Row(
                        children: [
                          _LegendDot(color: InnerscapeColors.violet,
                              label: 'Focus'),
                          const SizedBox(width: 16),
                          _LegendDot(color: InnerscapeColors.peach,
                              label: 'Fatigue'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly Insights card
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🔮', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text('Weekly Insights',
                              style: InnerscapeText.eyebrow()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your energy peaks after 10 PM. Consider deeper work then.',
                        style: InnerscapeText.serifItalic(
                          size: 15.5,
                          color: InnerscapeColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly aura grid
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This week's aura",
                          style: InnerscapeText.eyebrow()),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _WeekDay(label: 'M', hue: 0, active: true),
                          _WeekDay(label: 'T', hue: 35, active: true),
                          _WeekDay(label: 'W', hue: -30, active: true),
                          _WeekDay(label: 'T', hue: 70, active: true),
                          _WeekDay(label: 'F', hue: 0, active: false),
                          _WeekDay(label: 'S', hue: 0, active: false),
                          _WeekDay(label: 'S', hue: 0, active: false),
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
                    color: InnerscapeColors.lineStrong,
                    width: 1.5,
                  ),
                ),
              ),
        const SizedBox(height: 6),
        Text(
          label,
          style: InnerscapeText.body(
            size: 10,
            color: InnerscapeColors.mauve,
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
            color: InnerscapeColors.mauve,
          ),
        ),
      ],
    );
  }
}

// ── Focus vs Fatigue chart painter ────────────────────────────────────────────
class _FocusFatiguePainter extends CustomPainter {
  // Hardcoded sample data: Mon–Sun
  static const _focus = [0.55, 0.72, 0.48, 0.80, 0.65, 0.40, 0.90];
  static const _fatigue = [0.45, 0.30, 0.60, 0.25, 0.50, 0.70, 0.15];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final n = _focus.length;
    final step = w / (n - 1);

    // Draw smooth lines
    _drawLine(canvas, size, _focus, InnerscapeColors.violet, step, h);
    _drawLine(canvas, size, _fatigue, InnerscapeColors.peach, step, h);

    // Draw dots
    _drawDots(canvas, size, _focus, InnerscapeColors.violet, step, h);
    _drawDots(canvas, size, _fatigue, InnerscapeColors.peach, step, h);

    // Day labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      tp.text = TextSpan(
        text: _days[i],
        style: const TextStyle(
          fontFamily: 'BricolageGrotesque',
          fontSize: 9,
          color: InnerscapeColors.mauve,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(i * step - tp.width / 2, h - tp.height));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> data, Color color,
      double step, double h) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final chartH = h - 16; // reserve 16px for labels
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = chartH * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Smooth cubic bezier
        final prevX = (i - 1) * step;
        final prevY = chartH * (1 - data[i - 1]);
        final cp1x = prevX + step / 2;
        final cp2x = x - step / 2;
        path.cubicTo(cp1x, prevY, cp2x, y, x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawDots(Canvas canvas, Size size, List<double> data, Color color,
      double step, double h) {
    final paint = Paint()..color = color;
    final chartH = h - 16;
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(i * step, chartH * (1 - data[i])),
        3.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FocusFatiguePainter _) => false;
}
