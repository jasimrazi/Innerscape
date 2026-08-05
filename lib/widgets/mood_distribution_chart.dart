import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodDistributionChart extends StatelessWidget {
  final Map<String, int> distribution;

  const MoodDistributionChart({super.key, required this.distribution});

  static const _colors = {
    'Drained': Color(0xFFE57373),
    'Mellow':  Color(0xFFFFB74D),
    'Calm':    Color(0xFF4DB6AC),
    'Bright':  Color(0xFF64B5F6),
    'Radiant': Color(0xFFBA68C8),
  };

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text('No mood distribution yet', style: InnerscapeText.caption(color: context.colors.mauve)),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 80),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: CustomPaint(
              painter: _DonutPainter(distribution: distribution, total: total),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: distribution.entries.where((e) => e.value > 0).map((e) {
                final pct = (e.value / total * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _colors[e.key],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          e.key,
                          style: InnerscapeText.body(size: 10, color: context.colors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$pct%',
                        style: InnerscapeText.caption(size: 10, color: context.colors.mauve)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> distribution;
  final int total;

  _DonutPainter({required this.distribution, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const strokeWidth = 10.0;
    var startAngle = -pi / 2;

    final colors = {
      'Drained': const Color(0xFFE57373),
      'Mellow':  const Color(0xFFFFB74D),
      'Calm':    const Color(0xFF4DB6AC),
      'Bright':  const Color(0xFF64B5F6),
      'Radiant': const Color(0xFFBA68C8),
    };

    for (final entry in distribution.entries) {
      if (entry.value == 0) continue;
      final sweep = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = colors[entry.key]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep > 0.1 ? sweep - 0.04 : sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
