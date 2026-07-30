import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodTrendChart extends StatelessWidget {
  final List<({DateTime date, double mood})> data;
  final int days;

  const MoodTrendChart({super.key, required this.data, this.days = 30});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No mood data in the last $days days',
            style: InnerscapeText.caption(color: context.colors.mauve),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: CustomPaint(
        size: Size.infinite,
        painter: _TrendPainter(
          data: data,
          days: days,
          lineColor: context.colors.violet,
          fillColor: context.colors.violet.withValues(alpha: 0.12),
          gridColor: context.colors.line,
          mauveColor: context.colors.mauve,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<({DateTime date, double mood})> data;
  final int days;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color mauveColor;

  _TrendPainter({
    required this.data,
    required this.days,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.mauveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const chartLeft = 32.0;
    final chartBottom = size.height - 20;
    final chartWidth = size.width - chartLeft - 10;
    final chartHeight = chartBottom - 10;

    // Grid lines (5 horizontal for each mood level)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    for (var i = 0; i <= 4; i++) {
      final y = chartBottom - (i / 4) * chartHeight;
      canvas.drawLine(Offset(chartLeft, y), Offset(size.width - 10, y), gridPaint);
    }

    // Y-axis labels (mood emojis)
    const emojis = ['😔', '😐', '😌', '😊', '✨'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 4; i++) {
      final y = chartBottom - (i / 4) * chartHeight;
      textPainter.text = TextSpan(text: emojis[i], style: const TextStyle(fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(6, y - textPainter.height / 2));
    }

    // Plot data points
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startDate = todayMidnight.subtract(Duration(days: days - 1));

    final points = <Offset>[];
    for (final d in data) {
      final entryMidnight = DateTime(d.date.year, d.date.month, d.date.day);
      final dayOffset = entryMidnight.difference(startDate).inDays.toDouble();
      final x = chartLeft + (dayOffset / (days - 1)) * chartWidth;
      final y = chartBottom - (d.mood.clamp(0.0, 1.0)) * chartHeight;
      points.add(Offset(x.clamp(chartLeft, chartLeft + chartWidth), y));
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      canvas.drawCircle(points.first, 4, Paint()..color = lineColor);
      return;
    }

    // Draw smooth bezier line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final cp1x = (points[i - 1].dx + points[i].dx) / 2;
      path.cubicTo(cp1x, points[i - 1].dy, cp1x, points[i].dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Gradient fill under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, chartBottom)
      ..lineTo(points.first.dx, chartBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 10),
        Offset(0, chartBottom),
        [fillColor, fillColor.withValues(alpha: 0.0)],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Draw dots on data points
    final dotPaint = Paint()..color = lineColor;
    for (final p in points) {
      canvas.drawCircle(p, 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => true;
}
