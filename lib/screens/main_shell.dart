import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'today_screen.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    TodayScreen(),
    HistoryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _InnerscapeTabBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Custom Tab Bar ─────────────────────────────────────────────────────────────
class _InnerscapeTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _InnerscapeTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _TabItem(label: 'Today', iconPath: _TabIcon.today),
    _TabItem(label: 'History', iconPath: _TabIcon.history),
    _TabItem(label: 'Insights', iconPath: _TabIcon.insights),
    _TabItem(label: 'Settings', iconPath: _TabIcon.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: const Color(0xDBFBF7F0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                height: 1,
                thickness: 1,
                color: InnerscapeColors.line,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10 + bottom,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _tabs.asMap().entries.map((e) {
                    final idx = e.key;
                    final tab = e.value;
                    final isActive = currentIndex == idx;
                    return GestureDetector(
                      onTap: () => onTap(idx),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TabIconPainter(
                              icon: tab.iconPath,
                              active: isActive,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: InnerscapeText.bodyInter(
                                size: 9.5,
                                weight: FontWeight.w600,
                                color: isActive
                                    ? InnerscapeColors.ink
                                    : const Color(0xFFB3A6C2),
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedOpacity(
                              opacity: isActive ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: InnerscapeColors.violet,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final _TabIcon iconPath;
  const _TabItem({required this.label, required this.iconPath});
}

enum _TabIcon { today, history, insights, settings }

class _TabIconPainter extends StatelessWidget {
  final _TabIcon icon;
  final bool active;
  const _TabIconPainter({required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? InnerscapeColors.ink : const Color(0xFFB3A6C2);
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _IconPainter(icon: icon, color: color)),
    );
  }
}

class _IconPainter extends CustomPainter {
  final _TabIcon icon;
  final Color color;
  _IconPainter({required this.icon, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width;

    switch (icon) {
      case _TabIcon.today:
        // Circle with inner circle (aura-like)
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.38, paint);
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.14, paint);
        break;
      case _TabIcon.history:
        // Three lines (journal)
        final path = Path()
          ..moveTo(s * 0.17, s * 0.23)
          ..lineTo(s * 0.83, s * 0.23)
          ..moveTo(s * 0.17, s * 0.50)
          ..lineTo(s * 0.83, s * 0.50)
          ..moveTo(s * 0.17, s * 0.77)
          ..lineTo(s * 0.58, s * 0.77);
        canvas.drawPath(path, paint);
        break;
      case _TabIcon.insights:
        // Bar chart
        final path = Path()
          ..moveTo(s * 0.17, s * 0.83)
          ..lineTo(s * 0.17, s * 0.42)
          ..moveTo(s * 0.50, s * 0.83)
          ..lineTo(s * 0.50, s * 0.21)
          ..moveTo(s * 0.83, s * 0.83)
          ..lineTo(s * 0.83, s * 0.50);
        canvas.drawPath(path, paint);
        break;
      case _TabIcon.settings:
        // Gear: circle + outer ring hint
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.14, paint);
        canvas.drawCircle(Offset(s / 2, s / 2), s * 0.36, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color;
}
