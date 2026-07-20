import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/groq_sdk.dart';
import '../models/journal_entry.dart';

class WeeklyInsight {
  final String insight;
  final String theme;

  const WeeklyInsight({
    required this.insight,
    required this.theme,
  });
}

/// Calls Groq to generate a structured weekly insight from journal entries.
class InsightService {
  static const _model = GroqModels.llama3_8b;
  static Groq? _groq;

  static Groq? get _client {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'gsk_YOUR_GROQ_API_KEY_HERE') {
      return null;
    }
    _groq ??= Groq(apiKey);
    return _groq;
  }

  /// Generates a weekly insight from the given entries using Groq AI.
  /// Returns a [WeeklyInsight] on success, or null on failure.
  static Future<WeeklyInsight?> generateInsight(List<JournalEntry> entries) async {
    if (entries.isEmpty) return null;

    final client = _client;
    if (client == null) return null;

    try {
      if (!await client.canUseModel(_model)) return null;

      final chat = client.startNewChat(
        _model,
        settings: GroqChatSettings(
          temperature: 0.7,
          maxTokens: 256,
        ),
      );

      // Build a compact summary of entries — win + goal text
      final entryTexts = entries.map((e) {
        return '- Win: ${e.win}\n  Goal: ${e.goal}';
      }).join('\n');

      final prompt = '''
Analyze these journal entries from the past week.
Respond ONLY with a valid JSON object matching this structure exactly, with no markdown formatting or extra text:
{
  "insight": "One thoughtful sentence (max 20 words) reflecting on the person's week",
  "theme": "2-3 word theme"
}

Entries:
$entryTexts
''';

      final (response, _) = await chat.sendMessage(prompt, expectJSON: true);
      final text = response.choices.first.message;
      final Map<String, dynamic> json = jsonDecode(text) as Map<String, dynamic>;

      return WeeklyInsight(
        insight: json['insight'] as String? ?? '',
        theme: json['theme'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('Error generating Groq insight: $e');
      return null;
    }
  }
}
