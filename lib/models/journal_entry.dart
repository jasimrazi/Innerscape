/// Journal entry model with support for id, timestamp, mood, and aura ring hue.
class JournalEntry {
  final String id;
  final DateTime timestamp;
  final String date;
  final String win;
  final String goal;
  final double hueShift; // degrees, for AuraRing color variety
  final double moodValue; // 0.0 to 1.0

  const JournalEntry({
    required this.id,
    required this.timestamp,
    required this.date,
    required this.win,
    required this.goal,
    this.hueShift = 0,
    this.moodValue = 0.5,
  });
}

/// Sample data — mirrors the entries in the design.html prototype.
final List<JournalEntry> kSampleEntries = [
  JournalEntry(
    id: 'sample_1',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    date: 'Monday, July 6',
    win: 'Finally shipped the new UI onboarding flow — it felt good to just let it go.',
    goal: 'Set up the Innerscape revenue_cat integration.',
    hueShift: 0,
    moodValue: 0.8,
  ),
  JournalEntry(
    id: 'sample_2',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    date: 'Sunday, July 5',
    win: 'Slow morning, good coffee, no guilt about resting instead of rushing.',
    goal: 'Plan the week ahead over tea.',
    hueShift: 35,
    moodValue: 0.6,
  ),
  JournalEntry(
    id: 'sample_3',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    date: 'Saturday, July 4',
    win: 'Called my sister. We laughed for twenty minutes straight about nothing.',
    goal: 'Water the plants before they notice I forgot.',
    hueShift: -30,
    moodValue: 0.9,
  ),
  JournalEntry(
    id: 'sample_4',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    date: 'Friday, July 3',
    win: 'Pushed through the deadline without losing my temper, even when the file corrupted twice.',
    goal: 'Sleep before midnight, for once.',
    hueShift: 70,
    moodValue: 0.4,
  ),
];
