import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// A peaceful mood slider where the emojis sit on the track and the selected
/// one becomes the thumb — highlighted with a soft glowing ring.
class MoodSlider extends StatefulWidget {
  final double value; // 0.0 – 1.0
  final ValueChanged<double> onChanged;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MoodSlider> createState() => _MoodSliderState();
}

class _MoodSliderState extends State<MoodSlider> {
  static const _moods = [
    ('😔', 'Drained'),
    ('😐', 'Mellow'),
    ('😌', 'Calm'),
    ('😊', 'Bright'),
    ('✨', 'Radiant'),
  ];

  static const int _steps = 4; // _moods.length - 1

  int _lastHapticStep = -1;

  int get _selectedIndex =>
      (widget.value * _steps).round().clamp(0, _steps);

  void _onDrag(double localDx, double trackW, double pad) {
    final raw = (localDx - pad) / trackW;
    final clamped = raw.clamp(0.0, 1.0);

    final nearestStep = (clamped * _steps).round();
    if (nearestStep != _lastHapticStep) {
      _lastHapticStep = nearestStep;
      HapticFeedback.selectionClick();
    }

    // Snap to nearest step while dragging for a clean feel
    widget.onChanged(nearestStep / _steps);
  }

  void _onDragEnd() {
    _lastHapticStep = -1;
  }

  @override
  Widget build(BuildContext context) {
    final int sel = _selectedIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did today feel?',
          style: InnerscapeText.body(
            size: 12.5,
            color: InnerscapeColors.mauve,
          ),
        ),
        const SizedBox(height: 12),

        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double W = constraints.maxWidth;
              const double pad = 28.0;
              final double trackW = W - pad * 2;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) =>
                    _onDrag(d.localPosition.dx, trackW, pad),
                onHorizontalDragUpdate: (d) =>
                    _onDrag(d.localPosition.dx, trackW, pad),
                onHorizontalDragEnd: (_) => _onDragEnd(),
                onTapDown: (d) {
                  _onDrag(d.localPosition.dx, trackW, pad);
                },
                child: SizedBox(
                  height: 52,
                  width: W,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Track line ─────────────────────────────────
                      Positioned(
                        left: pad,
                        right: pad,
                        top: 24,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: InnerscapeColors.line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ── Active track fill ──────────────────────────
                      Positioned(
                        left: pad,
                        width: (sel / _steps) * trackW,
                        top: 24,
                        height: 4,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                InnerscapeColors.peachSoft,
                                InnerscapeColors.violet,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Sliding highlight ring (behind selected emoji) ─
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        left: pad + (sel / _steps) * trackW - 26,
                        top: 0,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: InnerscapeColors.violetSoft
                                .withValues(alpha: 0.55),
                            border: Border.all(
                              color: InnerscapeColors.violet
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: InnerscapeColors.violet
                                    .withValues(alpha: 0.12),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Emoji markers on track ─────────────────────
                      ...List.generate(_moods.length, (i) {
                        final double cx = pad + (i / _steps) * trackW;
                        final bool isSelected = i == sel;

                        return Positioned(
                          left: cx - 22,
                          width: 44,
                          top: 0,
                          height: 52,
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected ? 1.2 : 0.85,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1.0 : 0.45,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _moods[i].$1,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _moods[sel].$2,
              key: ValueKey(sel),
              style: InnerscapeText.serifItalic(
                size: 14.5,
                color: InnerscapeColors.inkSoft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
