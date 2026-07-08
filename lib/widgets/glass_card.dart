import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A glassmorphic card container — BackdropFilter + translucent white background.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: width,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: InnerscapeColors.glass,
            borderRadius: br,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.70),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x245A4678),
                blurRadius: 60,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
