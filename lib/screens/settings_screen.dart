import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    return Scaffold(
      backgroundColor: context.colors.cream,
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
                          color: context.colors.mauve,
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
                          color: context.colors.mauve,
                        ),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Reminders',
                      trailing: _Toggle(
                        value: provider.remindersOn,
                        onChanged: (v) => provider.setRemindersOn(v),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Appearance — Light',
                      trailing: _Toggle(
                        value: provider.lightMode,
                        onChanged: (v) => provider.setLightMode(v),
                      ),
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'Export journal',
                      trailing: Text(
                        '›',
                        style: InnerscapeText.body(
                          size: 17,
                          color: context.colors.mauve,
                        ),
                      ),
                      onTap: () {
                        // TODO: implement export journal
                      },
                    ),
                    const _Divider(),
                    _SettingsRow(
                      label: 'About Innerscape',
                      trailing: Text(
                        '›',
                        style: InnerscapeText.body(
                          size: 17,
                          color: context.colors.mauve,
                        ),
                      ),
                      onTap: () {
                        // TODO: implement about screen
                      },
                    ),
                    const Spacer(),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Innerscape v0.1.0',
                          style: InnerscapeText.body(
                            size: 11,
                            color: context.colors.hint,
                          ),
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
  final VoidCallback? onTap;
  const _SettingsRow({required this.label, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: InnerscapeText.serifItalic(
                size: 15,
                color: context.colors.ink,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap == null) return content;

    final pressed = ValueNotifier<bool>(false);
    return GestureDetector(
      onTapDown: (_) => pressed.value = true,
      onTapUp: (_) {
        pressed.value = false;
        onTap!();
      },
      onTapCancel: () => pressed.value = false,
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<bool>(
        valueListenable: pressed,
        builder: (context, isPressed, child) {
          return AnimatedOpacity(
            opacity: isPressed ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          );
        },
        child: content,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.line,
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
              ? LinearGradient(
                  colors: [context.colors.violet, context.colors.peach],
                )
              : null,
          color: value ? null : context.colors.lineStrong,
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
