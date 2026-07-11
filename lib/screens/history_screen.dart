import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../models/journal_entry.dart';
import 'detail_screen.dart';

import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final entriesList = provider.entries;

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
                  Text('Your journal', style: InnerscapeText.eyebrow()),
                  const SizedBox(height: 2),
                  Text('History', style: InnerscapeText.heading(size: 22)),
                ],
              ),
            ),
            Expanded(
              child: entriesList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 48,
                            color: context.colors.hint,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries yet',
                            style: InnerscapeText.heading(size: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your reflections will appear here',
                            style: InnerscapeText.serifItalic(
                              size: 14,
                              color: context.colors.mauve,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 20),
                      itemCount: entriesList.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: context.colors.line,
                        indent: 14,
                        endIndent: 14,
                      ),
                      itemBuilder: (context, i) {
                        final entry = entriesList[i];
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

class _EntryRow extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  const _EntryRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pressed = ValueNotifier<bool>(false);
    return GestureDetector(
      onTapDown: (_) => pressed.value = true,
      onTapUp: (_) {
        pressed.value = false;
        onTap();
      },
      onTapCancel: () => pressed.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: pressed,
        builder: (context, isPressed, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPressed
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuraRing(
                  size: AuraRingSize.sm,
                  hueShift: entry.hueShift,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.date,
                        style: InnerscapeText.body(
                          size: 11,
                          color: context.colors.mauve,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '"${entry.win}"',
                        style: InnerscapeText.serifItalic(size: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Goal: ${entry.goal}',
                        style: InnerscapeText.body(
                          size: 11.5,
                          color: context.colors.mauve,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.mauve,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
