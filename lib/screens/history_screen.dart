import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../models/journal_entry.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                  Text('Your journal', style: InnerscapeText.eyebrow()),
                  const SizedBox(height: 2),
                  Text('History', style: InnerscapeText.heading(size: 22)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                itemCount: kSampleEntries.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: InnerscapeColors.line,
                  indent: 14,
                  endIndent: 14,
                ),
                itemBuilder: (context, i) {
                  final entry = kSampleEntries[i];
                  return _EntryRow(
                    entry: entry,
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) =>
                            DetailScreen(entry: entry),
                        transitionsBuilder: (_, anim, _, child) =>
                            SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: anim, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration:
                            const Duration(milliseconds: 350),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends StatefulWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  const _EntryRow({required this.entry, required this.onTap});

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuraRing(
              size: AuraRingSize.sm,
              hueShift: widget.entry.hueShift,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.date,
                    style: InnerscapeText.body(
                      size: 11,
                      color: InnerscapeColors.mauve,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '"${widget.entry.win}"',
                    style: InnerscapeText.serifItalic(size: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Goal: ${widget.entry.goal}',
                    style: InnerscapeText.body(
                      size: 11.5,
                      color: InnerscapeColors.mauve,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: InnerscapeColors.mauve,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
