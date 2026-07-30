import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/journal_entry.dart';

class ExportService {
  static const _moodEmojis = ['😔', '😐', '😌', '😊', '✨'];
  static const _moodLabels = ['Drained', 'Mellow', 'Calm', 'Bright', 'Radiant'];

  /// Generates a clean white, print-friendly PDF file of all journal entries.
  static Future<File> generatePdf(List<JournalEntry> entries) async {
    final pdf = pw.Document();

    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final now = DateTime.now();
    final exportDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Cover / Header Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.5)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INNERSCAPE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Your Inner World, Mapped',
                          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Exported: $exportDateStr',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                        pw.SizedBox(height: 2),
                        pw.Text('${sortedEntries.length} Total Entries',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Journal Reflections',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
              pw.SizedBox(height: 16),
              ...sortedEntries.map((entry) => _buildEntryBlock(entry)),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/innerscape_journal_$exportDateStr.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildEntryBlock(JournalEntry entry) {
    final idx = (entry.moodValue * 4).round().clamp(0, 4);
    final moodEmoji = _moodEmojis[idx];
    final moodLabel = _moodLabels[idx];

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                entry.date,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
                child: pw.Text(
                  '$moodEmoji $moodLabel',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
                ),
              ),
            ],
          ),
          if (entry.tags.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              children: entry.tags.map((t) => pw.Container(
                margin: const pw.EdgeInsets.only(right: 4),
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('#$t', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
              )).toList(),
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Text('THE WIN:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(
            entry.win,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
          pw.SizedBox(height: 8),
          pw.Text("TOMORROW'S GOAL:", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(
            entry.goal,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  /// Generates the PDF and opens the native system share sheet.
  static Future<void> exportAndShare(List<JournalEntry> entries) async {
    final file = await generatePdf(entries);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My Innerscape Journal',
      text: 'Here is my exported Innerscape journal entries.',
    );
  }
}
