import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../database/daos/entries_dao.dart';
import '../database/daos/settings_dao.dart';
import '../services/sync_service.dart';
import '../services/insight_service.dart';

enum GroqInsightState { idle, loading, loaded, error }

class JournalProvider extends ChangeNotifier {
  final EntriesDao _entriesDao;
  final SettingsDao _settingsDao;

  // Groq AI Insight State
  WeeklyInsight? _groqInsight;
  WeeklyInsight? get groqInsight => _groqInsight;

  GroqInsightState _groqInsightState = GroqInsightState.idle;
  GroqInsightState get groqInsightState => _groqInsightState;

  Set<String> _groqInsightEntryIds = {};

  // Navigation State
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Journal Entries List
  List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => List.unmodifiable(_entries);

  // Streak Stats
  int _streak = 0;
  int get streak => _streak;

  int _longestStreak = 0;
  int get longestStreak => _longestStreak;

  int get totalEntries => _entries.length;

  // Settings State
  bool _lightMode = true;
  bool get lightMode => _lightMode;

  Future<void> setLightMode(bool val) async {
    _lightMode = val;
    await _settingsDao.set('light_mode', val.toString());
    notifyListeners();
  }

  bool _remindersOn = true;
  bool get remindersOn => _remindersOn;

  Future<void> setRemindersOn(bool val) async {
    _remindersOn = val;
    await _settingsDao.set('reminders_on', val.toString());
    notifyListeners();
  }

  // Today's Entry Input State
  double _moodValue = 0.5;
  double get moodValue => _moodValue;

  void setMoodValue(double val) {
    _moodValue = val;
    notifyListeners();
  }

  // Syncing state
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  double _ringHue = 0;
  double get ringHue => _ringHue;

  static const _captions = [
    'Take a breath before you write.',
    'Saved. Let it rest for tonight.',
    'One true thing, kept.',
    'Written and set down gently.',
  ];
  String _caption = _captions[0];
  String get caption => _caption;

  JournalProvider()
      : _entriesDao = EntriesDao(DatabaseHelper.instance),
        _settingsDao = SettingsDao(DatabaseHelper.instance);

  /// Initializes the provider by loading entries and settings from the database.
  Future<void> init() async {
    // Purge any residual sample/dummy entries from previous versions
    final db = await DatabaseHelper.instance.database;
    await db.delete('journal_entries', where: "id LIKE 'sample_%'");

    _entries = await _entriesDao.getAll();

    // Load settings from database
    final settings = await _settingsDao.getAll();
    _lightMode = (settings['light_mode'] ?? 'true') == 'true';
    _remindersOn = (settings['reminders_on'] ?? 'true') == 'true';

    // Calculate streaks
    _updateStreaks();

    notifyListeners();
  }

  /// Sync local SQLite database with Supabase cloud.
  Future<void> syncWithCloud(String userId) async {
    _isSyncing = true;
    notifyListeners();

    try {
      final merged = await SyncService.syncOnLogin(userId, _entries);
      
      // Update local SQLite with all merged entries
      for (final entry in merged) {
        await _entriesDao.insert(entry);
      }

      // Reload from local database
      _entries = await _entriesDao.getAll();
      _updateStreaks();
    } catch (e) {
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// All unique tags used across entries, sorted by frequency
  List<String> get allTags {
    final tagCount = <String, int>{};
    for (final entry in _entries) {
      for (final tag in entry.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    final sorted = tagCount.keys.toList()
      ..sort((a, b) => tagCount[b]!.compareTo(tagCount[a]!));
    return sorted;
  }

  // Add new entry and update stats
  /// Returns true if saved, false if inputs were empty.
  bool saveEntry(String winText, String goalText, {String? userId, List<String> tags = const []}) {
    // Reject empty entries
    if (winText.trim().isEmpty && goalText.trim().isEmpty) {
      return false;
    }

    final rng = math.Random();
    _ringHue = rng.nextDouble() * 60 - 30;
    _caption = _captions[1 + rng.nextInt(_captions.length - 1)];

    final now = DateTime.now();
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    // Format: "Thursday, July 9"
    final dateStr = "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";

    final trimmedTags = tags.map((t) => t.trim().toLowerCase()).where((t) => t.isNotEmpty).take(3).toList();

    final newEntry = JournalEntry(
      id: now.toIso8601String(),
      timestamp: now,
      date: dateStr,
      win: winText.trim(),
      goal: goalText.trim(),
      hueShift: _ringHue,
      moodValue: _moodValue,
      tags: trimmedTags,
    );

    // Save to memory
    _entries.insert(0, newEntry);

    // Save asynchronously to SQLite
    _entriesDao.insert(newEntry);

    // Save asynchronously to Supabase if signed in
    if (userId != null) {
      SyncService.upsertEntry(userId, newEntry).catchError((e) {
        debugPrint('Failed to sync new entry to cloud: $e');
      });
    }

    // Update streaks
    _updateStreaks();

    notifyListeners();
    return true;
  }

  void _updateStreaks() {
    _streak = _computeCurrentStreak();
    _longestStreak = _computeLongestStreak();
  }

  int _computeCurrentStreak() {
    if (_entries.isEmpty) return 0;

    // Get sorted, unique dates normalized to midnight local time
    final entryDates = _entries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // If the latest entry is before yesterday, the streak is broken
    final latestEntryDate = entryDates.first;
    if (latestEntryDate.isBefore(yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < entryDates.length - 1; i++) {
      final current = entryDates[i];
      final next = entryDates[i + 1];
      final diff = current.difference(next).inDays;

      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        break;
      }
    }
    return streak;
  }

  int _computeLongestStreak() {
    if (_entries.isEmpty) return 0;

    // Get sorted, unique dates normalized to midnight local time
    final entryDates = _entries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int longest = 1;
    int currentRun = 1;

    for (int i = 0; i < entryDates.length - 1; i++) {
      final current = entryDates[i];
      final next = entryDates[i + 1];
      final diff = current.difference(next).inDays;

      if (diff == 1) {
        currentRun++;
        if (currentRun > longest) {
          longest = currentRun;
        }
      } else if (diff > 1) {
        currentRun = 1;
      }
    }
    return longest;
  }

  /// Returns the Monday midnight DateTime for the target week.
  /// Uses current week if it has entries, otherwise falls back to the week of the most recent entry.
  DateTime get _targetWeekMonday {
    final now = DateTime.now();
    final currentMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    if (_entries.isEmpty) return currentMonday;

    // Check if any entry falls in the current calendar week
    final hasCurrentWeekEntry = _entries.any((e) {
      final diff = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)
          .difference(currentMonday)
          .inDays;
      return diff >= 0 && diff < 7;
    });

    if (hasCurrentWeekEntry) return currentMonday;

    // Fallback to the Monday of the week of the latest entry
    final latest = _entries.first.timestamp;
    return DateTime(latest.year, latest.month, latest.day).subtract(Duration(days: latest.weekday - 1));
  }

  /// Returns focus and fatigue values for Mon–Sun of the target week.
  /// Entries that fall on a given day are averaged.
  /// Days with no entry return null.
  ({List<double?> focus, List<double?> fatigue}) get weeklyFocusFatigue {
    final monday = _targetWeekMonday;

    final List<double?> focusList = List.filled(7, null);
    final List<double?> fatigueList = List.filled(7, null);
    final List<int> counts = List.filled(7, 0);

    for (final entry in _entries) {
      final entryDay = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      final diff = entryDay.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        if (focusList[diff] == null) {
          focusList[diff] = entry.moodValue;
        } else {
          focusList[diff] = focusList[diff]! + entry.moodValue;
        }
        counts[diff]++;
      }
    }

    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0 && focusList[i] != null) {
        final avgFocus = focusList[i]! / counts[i];
        focusList[i] = avgFocus;
        fatigueList[i] = 1.0 - avgFocus;
      }
    }

    return (focus: focusList, fatigue: fatigueList);
  }

  /// Generates a short, human-readable weekly insight string from mood data.
  String get weeklyInsightText {
    final data = weeklyFocusFatigue;
    final validFocus = data.focus.whereType<double>().toList();

    if (validFocus.isEmpty) {
      return 'Start logging to unlock your weekly patterns.';
    }

    final avg = validFocus.reduce((a, b) => a + b) / validFocus.length;
    double maxVal = -1.0;
    int peakDayIdx = -1;
    for (int i = 0; i < data.focus.length; i++) {
      final val = data.focus[i];
      if (val != null && val > maxVal) {
        maxVal = val;
        peakDayIdx = i;
      }
    }

    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final peakDayName = peakDayIdx >= 0 ? dayNames[peakDayIdx] : 'one of your days';
    final entryCount = validFocus.length;
    final missed = 7 - entryCount;

    if (avg >= 0.75) {
      return 'Exceptional week — your focus stayed high across $entryCount days. Keep this rhythm.';
    } else if (avg >= 0.6) {
      return '$peakDayName was your peak. You\'re in a steady groove — build on that momentum.';
    } else if (avg >= 0.4) {
      if (missed > 2) {
        return 'You logged $entryCount days this week. Even showing up halfway is progress.';
      }
      return 'A balanced week. Your energy on $peakDayName stood out — chase more days like that.';
    } else {
      return 'Rough week, but you\'re still here. Rest is data too. Tomorrow is a fresh start.';
    }
  }

  /// Returns aura data (active status & latest hueShift) for Mon-Sun of target week.
  List<({bool active, double hue})> get weeklyAuraData {
    final monday = _targetWeekMonday;

    final result = List.generate(7, (_) => (active: false, hue: 0.0));

    for (final entry in _entries.reversed) {
      final entryDay = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      final diff = entryDay.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        result[diff] = (active: true, hue: entry.hueShift);
      }
    }
    return result;
  }

  /// Returns entries that fall within the target week.
  List<JournalEntry> _entriesInTargetWeek() {
    final monday = _targetWeekMonday;
    return _entries.where((e) {
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final diff = day.difference(monday).inDays;
      return diff >= 0 && diff < 7;
    }).toList();
  }

  /// Fetches a Groq insight if needed (cached per set of entry IDs).
  Future<void> refreshGroqInsight({bool force = false}) async {
    if (_groqInsightState == GroqInsightState.loading) return;

    final targetEntries = _entriesInTargetWeek();
    final currentIds = targetEntries.map((e) => e.id).toSet();

    if (!force &&
        _groqInsightState != GroqInsightState.idle &&
        currentIds.length == _groqInsightEntryIds.length &&
        currentIds.containsAll(_groqInsightEntryIds)) {
      return; // Already attempted or loaded for these exact entries
    }

    if (targetEntries.isEmpty) {
      _groqInsight = null;
      _groqInsightState = GroqInsightState.idle;
      _groqInsightEntryIds = {};
      notifyListeners();
      return;
    }

    _groqInsightState = GroqInsightState.loading;
    _groqInsightEntryIds = currentIds;
    notifyListeners();

    final result = await InsightService.generateInsight(targetEntries);

    if (result != null) {
      _groqInsight = result;
      _groqInsightState = GroqInsightState.loaded;
    } else {
      _groqInsightState = GroqInsightState.error;
    }
    notifyListeners();
  }

  // Breathing Guide State
  bool _isBreathing = false;
  bool get isBreathing => _isBreathing;

  String _breathingText = 'Hold to breathe';
  String get breathingText => _breathingText;

  void setBreathing(bool val) {
    _isBreathing = val;
    notifyListeners();
  }

  void setBreathingText(String val) {
    _breathingText = val;
    notifyListeners();
  }

  // Toast Visibility State
  bool _showToast = false;
  bool get showToast => _showToast;

  void setShowToast(bool val) {
    _showToast = val;
    notifyListeners();
  }

  // ── Long-term Trends Analytics ──────────────────────────────────────────────
  List<({DateTime date, double mood})> moodTrendData(int days) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final cutoff = todayMidnight.subtract(Duration(days: days - 1));

    final filtered = _entries
        .where((e) => e.timestamp.isAfter(cutoff) || e.timestamp.isAtSameMomentAs(cutoff))
        .map((e) => (date: e.timestamp, mood: e.moodValue))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return filtered;
  }

  Map<String, int> get moodDistribution {
    const labels = ['Drained', 'Mellow', 'Calm', 'Bright', 'Radiant'];
    final dist = {for (final l in labels) l: 0};
    for (final e in _entries) {
      final idx = (e.moodValue * 4).round().clamp(0, 4);
      dist[labels[idx]] = dist[labels[idx]]! + 1;
    }
    return dist;
  }

  double get monthlyConsistency {
    final now = DateTime.now();
    final daysElapsed = now.day;
    final thisMonthCount = _entries.where((e) =>
      e.timestamp.year == now.year && e.timestamp.month == now.month
    ).map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)).toSet().length;

    return daysElapsed > 0 ? (thisMonthCount / daysElapsed).clamp(0.0, 1.0) : 0.0;
  }

  double get averageMoodThisMonth {
    final now = DateTime.now();
    final monthEntries = _entries.where((e) =>
      e.timestamp.year == now.year && e.timestamp.month == now.month
    ).toList();
    if (monthEntries.isEmpty) return 0.5;
    final sum = monthEntries.map((e) => e.moodValue).reduce((a, b) => a + b);
    return sum / monthEntries.length;
  }

  double get averageMoodLastMonth {
    final now = DateTime.now();
    final lastMonthDate = DateTime(now.year, now.month - 1);
    final entries = _entries.where((e) =>
      e.timestamp.year == lastMonthDate.year && e.timestamp.month == lastMonthDate.month
    ).toList();
    if (entries.isEmpty) return 0.5;
    final sum = entries.map((e) => e.moodValue).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  int get moodTrend {
    final diff = averageMoodThisMonth - averageMoodLastMonth;
    if (diff > 0.05) return 1;
    if (diff < -0.05) return -1;
    return 0;
  }
}
