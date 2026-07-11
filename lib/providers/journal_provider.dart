import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../database/database_helper.dart';
import '../database/daos/entries_dao.dart';
import '../database/daos/settings_dao.dart';

class JournalProvider extends ChangeNotifier {
  final EntriesDao _entriesDao;
  final SettingsDao _settingsDao;

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
  /// Seeds sample data if the database is empty.
  Future<void> init() async {
    _entries = await _entriesDao.getAll();

    // Seed sample data on first run
    if (_entries.isEmpty) {
      for (final entry in kSampleEntries) {
        await _entriesDao.insert(entry);
      }
      _entries = await _entriesDao.getAll();
    }

    // Load settings from database
    final settings = await _settingsDao.getAll();
    _lightMode = (settings['light_mode'] ?? 'true') == 'true';
    _remindersOn = (settings['reminders_on'] ?? 'true') == 'true';

    // Calculate streaks
    _updateStreaks();

    notifyListeners();
  }

  // Add new entry and update stats
  /// Returns true if saved, false if inputs were empty.
  bool saveEntry(String winText, String goalText) {
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

    final newEntry = JournalEntry(
      id: now.toIso8601String(),
      timestamp: now,
      date: dateStr,
      win: winText.trim(),
      goal: goalText.trim(),
      hueShift: _ringHue,
      moodValue: _moodValue,
    );

    // Save to memory
    _entries.insert(0, newEntry);

    // Save asynchronously to SQLite
    _entriesDao.insert(newEntry);

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
}
