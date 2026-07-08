import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A horizontal glassmorphic mood slider with emoji markers and a soft amber
/// glow tracking the thumb. Mimics the design brief's "Slide to reflect" element.
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
  // Emoji markers spaced evenly along the track
  static const _markers = ['😔', '😐', '😌', '😊', '✨'];
  static const _labels = ['Drained', 'Mellow', 'Calm & Centered', 'Energised', 'Radiant'];

  String get _currentLabel {
    final idx = (widget.value * (_labels.length - 1)).round();
    return _labels[idx.clamp(0, _labels.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt text
        Text(
          'Slide to reflect: How was your energy today?',
          style: InnerscapeText.bodyInter(
            size: 12.5,
            color: InnerscapeColors.mauve,
          ),
        ),
        const SizedBox(height: 14),

        // Glass slider container
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.70),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x145A4678),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Amber glow under thumb
                  Positioned(
                    left: widget.value * (MediaQuery.of(context).size.width - 80) -
                        24,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF6C39A).withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Emoji markers row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _markers
                          .asMap()
                          .entries
                          .map((e) => Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: widget.value >=
                                          (e.key / (_markers.length - 1)) - 0.05 &&
                                      widget.value <=
                                          (e.key / (_markers.length - 1)) + 0.05
                                      ? 26
                                      : 18,
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // Invisible slider gesture layer
                  Positioned.fill(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 14,
                          elevation: 6,
                        ),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0x20F6C39A),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 22,
                        ),
                      ),
                      child: Slider(
                        value: widget.value,
                        onChanged: widget.onChanged,
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Descriptive label
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _currentLabel,
              key: ValueKey(_currentLabel),
              style: InnerscapeText.serifItalic(
                size: 14,
                color: InnerscapeColors.inkSoft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
