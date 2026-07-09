import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

enum AuraRingSize { xs, sm, md, lg }

/// The signature animated aura ring — a spinning conic-gradient ring with a
/// blurred glow layer underneath and a frosted-glass core on top.
class AuraRing extends StatefulWidget {
  final AuraRingSize size;

  /// Hue rotation in degrees (mimics CSS `filter: hue-rotate(Xdeg)`)
  final double hueShift;

  const AuraRing({
    super.key,
    this.size = AuraRingSize.md,
    this.hueShift = 0,
  });

  @override
  State<AuraRing> createState() => _AuraRingState();
}

class _AuraRingState extends State<AuraRing> with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  double get _diameter {
    switch (widget.size) {
      case AuraRingSize.xs:
        return 26;
      case AuraRingSize.sm:
        return 44;
      case AuraRingSize.md:
        return 96;
      case AuraRingSize.lg:
        return 220;
    }
  }

  double get _coreInsetFraction {
    switch (widget.size) {
      case AuraRingSize.xs:
        return 0.18;
      case AuraRingSize.sm:
        return 0.16;
      case AuraRingSize.md:
        return 0.15;
      case AuraRingSize.lg:
        return 0.14;
    }
  }

  Color _hueRotate(Color color, double degrees) {
    if (degrees == 0) return color;
    final rad = degrees * math.pi / 180;
    final cosA = math.cos(rad);
    final sinA = math.sin(rad);
    final r = color.r;
    final g = color.g;
    final b = color.b;
    final sq3 = math.sqrt(3.0);

    final nr = r * (cosA + (1 - cosA) / 3 - sinA / sq3) +
        g * ((1 - cosA) / 3 - sinA / sq3) +
        b * ((1 - cosA) / 3 + sinA * sq3 / 3);
    final ng = r * ((1 - cosA) / 3 + sinA / sq3) +
        g * (cosA + (1 - cosA) / 3) +
        b * ((1 - cosA) / 3 - sinA / sq3);
    final nb = r * ((1 - cosA) / 3 - sinA * sq3 / 3) +
        g * ((1 - cosA) / 3 + sinA / sq3) +
        b * (cosA + (1 - cosA) / 3);

    return Color.fromARGB(
      (color.a * 255).round().clamp(0, 255),
      (nr.clamp(0.0, 1.0) * 255).round(),
      (ng.clamp(0.0, 1.0) * 255).round(),
      (nb.clamp(0.0, 1.0) * 255).round(),
    );
  }

  List<Color> get _gradientColors {
    final base = [
      InnerscapeColors.violet,
      InnerscapeColors.peach,
      InnerscapeColors.violetSoft,
      InnerscapeColors.violet,
    ];
    return base.map((c) => _hueRotate(c, widget.hueShift)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final d = _diameter;
    final coreD = d * (1 - _coreInsetFraction * 2);
    final glowD = d * 1.36;
    final blurSigma = (widget.size == AuraRingSize.xs ||
            widget.size == AuraRingSize.sm)
        ? 6.0
        : 26.0;
    final colors = _gradientColors;

    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Glow (blurred spinning gradient) ─────────────────────
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, _) => Transform.rotate(
              angle: _glowCtrl.value * 2 * math.pi,
              child: SizedBox(
                width: glowD,
                height: glowD,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Opacity(
                    opacity: 0.55,
                    child: CustomPaint(
                      painter: _SweepCirclePainter(
                        colors: colors,
                        startAngle: 2.09,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Ring (sharp spinning gradient) ───────────────────────
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, _) => Transform.rotate(
              angle: _ringCtrl.value * 2 * math.pi,
              child: SizedBox(
                width: d,
                height: d,
                child: CustomPaint(
                  painter: _SweepCirclePainter(
                    colors: colors,
                    startAngle: 3.49,
                  ),
                ),
              ),
            ),
          ),

          // ── Core (frosted glass) ──────────────────────────────────
          ClipOval(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                width: coreD,
                height: coreD,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: InnerscapeColors.card.withValues(alpha: 0.72),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.7),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that fills a circle with a SweepGradient.
class _SweepCirclePainter extends CustomPainter {
  final List<Color> colors;
  final double startAngle;

  _SweepCirclePainter({required this.colors, required this.startAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi,
        colors: colors,
      ).createShader(rect);
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(_SweepCirclePainter old) =>
      old.colors != colors || old.startAngle != startAngle;
}
