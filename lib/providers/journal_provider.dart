import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  // Navigation State
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Journal Entries List
  final List<JournalEntry> _entries = List.from(kSampleEntries);
  List<JournalEntry> get entries => List.unmodifiable(_entries);

  // Streak Stats
  int _streak = 12;
  int get streak => _streak;

  int _longestStreak = 31;
  int get longestStreak => _longestStreak;

  int get totalEntries => _entries.length + 142; // Maintaining prototype base of 146

  // Settings State
  bool _lightMode = true;
  bool get lightMode => _lightMode;

  void setLightMode(bool val) {
    _lightMode = val;
    notifyListeners();
  }

  bool _remindersOn = true;
  bool get remindersOn => _remindersOn;

  void setRemindersOn(bool val) {
    _remindersOn = val;
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

  // Add new entry and update stats
  void saveEntry(String winText, String goalText) {
    final rng = math.Random();
    _ringHue = rng.nextDouble() * 60 - 30;
    _caption = _captions[1 + rng.nextInt(_captions.length - 1)];

    final now = DateTime.now();
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    // Format: "Thursday, July 9"
    final dateStr = "${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}";

    final newEntry = JournalEntry(
      id: now.toIso8601String(),
      timestamp: now,
      date: dateStr,
      win: winText,
      goal: goalText,
      hueShift: _ringHue,
      moodValue: _moodValue,
    );

    _entries.insert(0, newEntry);
    _streak += 1;
    if (_streak > _longestStreak) {
      _longestStreak = _streak;
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
}
