import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_ring.dart';
import '../widgets/glass_card.dart';
import '../models/journal_entry.dart';
import 'detail_screen.dart';

import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedMoodFilter;
  String? _selectedTagFilter;

  String _getMoodLabel(double moodValue) {
    const labels = ['Drained', 'Mellow', 'Calm', 'Bright', 'Radiant'];
    return labels[(moodValue * 4).round().clamp(0, 4)];
  }

  List<JournalEntry> _filterEntries(List<JournalEntry> entries) {
    return entries.where((e) {
      // 1. Text search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchWin = e.win.toLowerCase().contains(q);
        final matchGoal = e.goal.toLowerCase().contains(q);
        final matchDate = e.date.toLowerCase().contains(q);
        final matchMood = _getMoodLabel(e.moodValue).toLowerCase().contains(q);
        final matchTags = e.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchWin && !matchGoal && !matchDate && !matchMood && !matchTags) {
          return false;
        }
      }

      // 2. Mood filter
      if (_selectedMoodFilter != null) {
        if (_getMoodLabel(e.moodValue) != _selectedMoodFilter) {
          return false;
        }
      }

      // 3. Tag filter
      if (_selectedTagFilter != null) {
        if (!e.tags.contains(_selectedTagFilter)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final allEntries = provider.entries;
    final filteredEntries = _filterEntries(allEntries);
    final allTags = provider.allTags;

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
                  Text('Your journal', style: InnerscapeText.eyebrow(color: context.colors.mauve)),
                  const SizedBox(height: 2),
                  Text('History', style: InnerscapeText.heading(size: 22, color: context.colors.ink)),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: TextField(
                  controller: _searchCtrl,
                  style: InnerscapeText.body(size: 14, color: context.colors.ink),
                  decoration: InputDecoration(
                    hintText: 'Search entries by text, mood, or #tag...',
                    hintStyle: InnerscapeText.caption(size: 13, color: context.colors.hint),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: context.colors.mauve),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Icon(Icons.close_rounded, size: 18, color: context.colors.mauve),
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
            ),

            // Filter Chips (Mood & Tags)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Mood Chips
                    for (final label in ['Drained', 'Mellow', 'Calm', 'Bright', 'Radiant']) ...[
                      _FilterChip(
                        label: label,
                        isSelected: _selectedMoodFilter == label,
                        onTap: () {
                          setState(() {
                            _selectedMoodFilter = _selectedMoodFilter == label ? null : label;
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Separator if tags exist
                    if (allTags.isNotEmpty) ...[
                      Container(
                        height: 16,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: context.colors.line,
                      ),
                      const SizedBox(width: 4),
                    ],

                    // Tag Chips
                    for (final tag in allTags) ...[
                      _FilterChip(
                        label: '#$tag',
                        isSelected: _selectedTagFilter == tag,
                        onTap: () {
                          setState(() {
                            _selectedTagFilter = _selectedTagFilter == tag ? null : tag;
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),

            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 44,
                            color: context.colors.hint,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            allEntries.isEmpty ? 'No entries yet' : 'No matching entries',
                            style: InnerscapeText.heading(size: 18, color: context.colors.ink),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allEntries.isEmpty
                                ? 'Your reflections will appear here'
                                : 'Try adjusting your search or filters',
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
                      itemCount: filteredEntries.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: context.colors.line,
                        indent: 14,
                        endIndent: 14,
                      ),
                      itemBuilder: (context, i) {
                        final entry = filteredEntries[i];
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.violet.withValues(alpha: 0.18)
              : context.colors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? context.colors.violet.withValues(alpha: 0.4)
                : context.colors.line,
          ),
        ),
        child: Text(
          label,
          style: InnerscapeText.caption(
            color: isSelected ? context.colors.violet : context.colors.mauve,
          ).copyWith(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
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
                  ? context.colors.glass
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
                        style: InnerscapeText.serifItalic(size: 15, color: context.colors.inkSoft),
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
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.violet.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: InnerscapeText.caption(color: context.colors.violet).copyWith(fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          )).toList(),
                        ),
                      ],
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
