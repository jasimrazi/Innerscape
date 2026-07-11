/// List of SQL migrations for the Innerscape app.
/// Every element corresponds to a version of the database schema (1-indexed).
const List<String> kMigrations = [
  // Version 1: Initial schema with journal entries and settings tables
  '''
  CREATE TABLE journal_entries (
    id TEXT PRIMARY KEY,
    timestamp INTEGER NOT NULL,
    date TEXT NOT NULL,
    win TEXT NOT NULL,
    goal TEXT NOT NULL,
    hue_shift REAL NOT NULL DEFAULT 0,
    mood_value REAL NOT NULL DEFAULT 0.5
  )
  ''',
  '''
  CREATE TABLE user_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  )
  ''',
];
