/// Hardcoded sample journal entries for the Innerscape prototype.
class JournalEntry {
  final String date;
  final String win;
  final String goal;
  final double hueShift; // degrees, for AuraRing color variety

  const JournalEntry({
    required this.date,
    required this.win,
    required this.goal,
    this.hueShift = 0,
  });
}

/// Sample data — mirrors the entries in the design.html prototype.
const List<JournalEntry> kSampleEntries = [
  JournalEntry(
    date: 'Monday, July 6',
    win:
        'Finally shipped the new UI onboarding flow — it felt good to just let it go.',
    goal: 'Set up the Innerscape revenue_cat integration.',
    hueShift: 0,
  ),
  JournalEntry(
    date: 'Sunday, July 5',
    win: 'Slow morning, good coffee, no guilt about resting instead of rushing.',
    goal: 'Plan the week ahead over tea.',
    hueShift: 35,
  ),
  JournalEntry(
    date: 'Saturday, July 4',
    win:
        'Called my sister. We laughed for twenty minutes straight about nothing.',
    goal: 'Water the plants before they notice I forgot.',
    hueShift: -30,
  ),
  JournalEntry(
    date: 'Friday, July 3',
    win:
        'Pushed through the deadline without losing my temper, even when the file corrupted twice.',
    goal: 'Sleep before midnight, for once.',
    hueShift: 70,
  ),
];
