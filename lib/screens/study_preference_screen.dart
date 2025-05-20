import 'package:flutter/material.dart';
import 'exam_plan_screen.dart';
import '../app_texts.dart'; // ✅ استيراد الترجمة

class StudyPreferenceScreen extends StatefulWidget {
  final String subject;
  final DateTime examDate;
  final int availableDays;
  final String studentId;

  const StudyPreferenceScreen({
    super.key,
    required this.subject,
    required this.examDate,
    required this.availableDays,
    required this.studentId,
  });

  @override
  State<StudyPreferenceScreen> createState() => _StudyPreferenceScreenState();
}

class _StudyPreferenceScreenState extends State<StudyPreferenceScreen> {
  bool? withBreaks;

  void _proceed() {
    if (withBreaks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.of(context).choosePreferenceWarning)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamPlanScreen(
          subject: widget.subject,
          examDate: widget.examDate,
          availableDays: widget.availableDays,
          withBreaks: withBreaks!,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(texts.studyPreferencesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(texts.studyWithBreaksQuestion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            RadioListTile<bool>(
              title: Text(texts.optionWithBreaks),
              value: true,
              groupValue: withBreaks,
              onChanged: (val) => setState(() => withBreaks = val),
            ),
            RadioListTile<bool>(
              title: Text(texts.optionWithoutBreaks),
              value: false,
              groupValue: withBreaks,
              onChanged: (val) => setState(() => withBreaks = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _proceed,
              child: Text(texts.continueButton),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
