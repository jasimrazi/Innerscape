import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/groq_sdk.dart';
import '../models/journal_entry.dart';

class WeeklyInsight {
  final String overallMood;
  final List<String> positiveThemes;
  final String growthArea;

  const WeeklyInsight({
    required this.overallMood,
    required this.positiveThemes,
    required this.growthArea,
  });

  factory WeeklyInsight.fromJson(Map<String, dynamic> json) {
    final themes = (json['positive_themes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return WeeklyInsight(
      overallMood: json['overall_mood'] as String? ?? '',
      positiveThemes: themes,
      growthArea: json['growth_area'] as String? ?? '',
    );
  }
}

/// Calls Groq to generate a structured weekly insight from journal entries.
class InsightService {
  static const _model = 'llama-3.3-70b-versatile';
  static Groq? _groq;

  static Groq? get _client {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'gsk_YOUR_GROQ_API_KEY_HERE') {
      debugPrint('[Groq AI] API Key missing or placeholder in .env!');
      return null;
    }
    _groq ??= Groq(apiKey);
    return _groq;
  }

  /// Generates a weekly insight from the given entries using Groq AI.
  /// Returns a [WeeklyInsight] on success, or null on failure.
  static Future<WeeklyInsight?> generateInsight(
    List<JournalEntry> entries,
  ) async {
    if (entries.isEmpty) {
      debugPrint('[Groq AI] No entries provided to generate insight.');
      return null;
    }

    final client = _client;
    if (client == null) return null;

    try {
      debugPrint('[Groq AI] Checking availability for model $_model...');
      final canUse = await client.canUseModel(_model);
      if (!canUse) {
        debugPrint('[Groq AI] Model $_model is unavailable.');
        return null;
      }

      debugPrint(
        '[Groq AI] Starting chat session with ${entries.length} entries using $_model...',
      );
      final chat = client.startNewChat(
        _model,
        settings: GroqChatSettings(temperature: 0.7, maxTokens: 256),
      );

      // Build a compact summary of entries — win + goal text
      final entryTexts = entries
          .map((e) {
            return '- Win: ${e.win}\n  Goal: ${e.goal}';
          })
          .join('\n');

      final prompt = '''
Analyze the following journal entries from the past week. 
      Respond ONLY with a valid JSON object matching this structure exactly, with no markdown formatting or extra text:
      {
        "overall_mood": "A short 2-word summary",
        "positive_themes": ["theme 1", "theme 2"],
        "growth_area": "One sentence on what to focus on next week"
      }
      
      Entries:
      $entryTexts
''';

      debugPrint('[Groq AI] Sending prompt to Groq...');
      final (response, usage) = await chat.sendMessage(
        prompt,
        expectJSON: true,
      );
      final text = response.choices.first.message;

      debugPrint('[Groq AI] Raw Response: $text');
      debugPrint(
        '[Groq AI] Usage: promptTokens=${usage.promptTokens}, completionTokens=${usage.completionTokens}, totalTokens=${usage.totalTokens}',
      );

      final Map<String, dynamic> json =
          jsonDecode(text) as Map<String, dynamic>;
      final insightResult = WeeklyInsight.fromJson(json);

      debugPrint(
        '[Groq AI] Parsed Insight — Mood: "${insightResult.overallMood}", Themes: ${insightResult.positiveThemes}, Growth Area: "${insightResult.growthArea}"',
      );
      return insightResult;
    } catch (e, stack) {
      debugPrint('[Groq AI] Error generating Groq insight: $e');
      debugPrint('[Groq AI] Stacktrace: $stack');
      return null;
    }
  }
}
