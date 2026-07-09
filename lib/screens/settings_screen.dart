import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lightMode = true;
  bool _remindersOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InnerscapeColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your space', style: InnerscapeText.eyebrow()),
                  const SizedBox(height: 2),
                  Text('Settings', style: InnerscapeText.heading(size: 22)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    _SettingsRow(
                      label: 'Evening reminder',
                      trailing: Text(
                        '8:00 PM',
                        style: InnerscapeText.body(
                          size: 13,
                          color: InnerscapeColors.mauve,
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Reminder sound',
                      trailing: Text(
                        'Soft chime',
                        style: InnerscapeText.body(
                          size: 13,
                          color: InnerscapeColors.mauve,
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Reminders',
                      trailing: _Toggle(
                        value: _remindersOn,
                        onChanged: (v) => setState(() => _remindersOn = v),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Appearance — Light',
                      trailing: _Toggle(
                        value: _lightMode,
                        onChanged: (v) => setState(() => _lightMode = v),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Export journal',
                      trailing: Text(
                        '›',
                        style: InnerscapeText.body(
                          size: 17,
                          color: InnerscapeColors.mauve,
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'About Innerscape',
                      trailing: Text(
                        '›',
                        style: InnerscapeText.body(
                          size: 17,
                          color: InnerscapeColors.mauve,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _SettingsRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: InnerscapeText.serifItalic(
              size: 15,
              color: InnerscapeColors.ink,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: InnerscapeColors.line,
    );
  }
}

// ── Animated toggle ────────────────────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: value
              ? const LinearGradient(
                  colors: [InnerscapeColors.violet, InnerscapeColors.peach],
                )
              : null,
          color: value ? null : InnerscapeColors.lineStrong,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 19.5 : 2.5,
              top: 2.5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
