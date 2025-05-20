import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_helper.dart';
import 'weekly_study_screen.dart';
import '../app_texts.dart';

// ✅ دعم التحقق من النظام لتجنب الإشعارات على الويب
import 'dart:io' show Platform;

class ExamPlanScreen extends StatefulWidget {
  final String subject;
  final DateTime examDate;
  final int availableDays;
  final bool withBreaks;
  final String studentId;

  const ExamPlanScreen({
    super.key,
    required this.subject,
    required this.examDate,
    required this.availableDays,
    required this.withBreaks,
    required this.studentId,
  });

  @override
  State<ExamPlanScreen> createState() => _ExamPlanScreenState();
}

class _ExamPlanScreenState extends State<ExamPlanScreen> {
  final Map<int, TextEditingController> hourControllers = {};
  int currentDayIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.availableDays; i++) {
      hourControllers[i] = TextEditingController();
    }
  }

  void _nextOrFinish() async {
    final input = hourControllers[currentDayIndex]?.text ?? '';
    final hours = int.tryParse(input);

    final texts = AppTexts.of(context);

    if (hours == null || hours <= 0 || hours > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts.invalidHourRange)),
      );
      return;
    }

    if (currentDayIndex < widget.availableDays - 1) {
      setState(() => currentDayIndex++);
    } else {
      await _generateSessions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts.examAddedSuccessfully)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WeeklyStudyScreen(studentId: widget.studentId),
        ),
      );
    }
  }

  Future<void> _generateSessions() async {
    final List<Map<String, dynamic>> sessions = [];
    final Map<String, Set<int>> usedHoursByDay = {};

    final docSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (docSnapshot.docs.isEmpty) return;

    final docId = docSnapshot.docs.first.id;
    final docData = docSnapshot.docs.first.data();
    List<Map<String, dynamic>> existingSessions = List<Map<String, dynamic>>.from(docData['study_sessions'] ?? []);

    for (int i = 0; i < widget.availableDays; i++) {
      final input = hourControllers[i]?.text ?? '';
      int studyHours = int.tryParse(input) ?? 0;
      final studyDate = widget.examDate.subtract(Duration(days: widget.availableDays - 1 - i));
      final String dateKey = '${studyDate.year}-${studyDate.month}-${studyDate.day}';

      final Set<int> occupiedHours = existingSessions
          .where((s) {
        final dynamic rawStart = s['start'];
        final DateTime start = rawStart is Timestamp ? rawStart.toDate() : rawStart as DateTime;
        return start.year == studyDate.year &&
            start.month == studyDate.month &&
            start.day == studyDate.day;
      })
          .map((s) {
        final dynamic rawStart = s['start'];
        final DateTime start = rawStart is Timestamp ? rawStart.toDate() : rawStart as DateTime;
        return start.hour;
      })
          .toSet();

      usedHoursByDay[dateKey] = {...occupiedHours};

      int attempts = 0;

      for (int h = 0; h < studyHours; h++) {
        int randomHour;
        do {
          randomHour = 14 + Random().nextInt(7); // بين 14:00 و 20:00
          attempts++;
        } while (usedHoursByDay[dateKey]!.contains(randomHour) && attempts < 30);

        if (usedHoursByDay[dateKey]!.contains(randomHour)) continue;
        usedHoursByDay[dateKey]!.add(randomHour);

        final studyStart = DateTime(studyDate.year, studyDate.month, studyDate.day, randomHour, 0);

        if (widget.withBreaks) {
          final breakStart = studyStart.add(const Duration(minutes: 45));
          existingSessions.add({
            'subject': widget.subject,
            'start': studyStart,
            'type': 'study',
            'duration': 45
          });
          existingSessions.add({
            'subject': widget.subject,
            'start': breakStart,
            'type': 'break',
            'duration': 15
          });
          sessions.add({'start': studyStart, 'type': 'study'});
          sessions.add({'start': breakStart, 'type': 'break'});
        } else {
          final studyEnd = studyStart.add(const Duration(minutes: 60));
          existingSessions.add({
            'subject': widget.subject,
            'start': studyStart,
            'end': studyEnd,
            'type': 'study',
            'duration': 60,
            'label': '${studyStart.hour.toString().padLeft(2, '0')}:${studyStart.minute.toString().padLeft(2, '0')}'
                '-${studyEnd.hour.toString().padLeft(2, '0')}:${studyEnd.minute.toString().padLeft(2, '0')}'
          });
          sessions.add({'start': studyStart, 'type': 'study'});
        }
      }
    }

    await FirebaseFirestore.instance
        .collection('students')
        .doc(docId)
        .update({'study_sessions': existingSessions});

    // ✅ منع كسر الإشعارات على الويب
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        for (var session in sessions) {
          await NotificationsHelper.scheduleNotification(
            title: session['type'] == 'study' ? '📚 وقت الدراسة' : '☕ وقت الاستراحة',
            body: session['type'] == 'study'
                ? 'ابدأ دراسة ${widget.subject} الآن!'
                : 'خذ استراحة قصيرة ثم ارجع للمذاكرة! 💪',
            scheduledDate: session['start'],
          );
        }
      }
    } catch (_) {
      // لا تفعل شيء على الويب
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    final studyDate = widget.examDate.subtract(Duration(days: widget.availableDays - 1 - currentDayIndex));
    final readableDate = "${studyDate.day}/${studyDate.month}/${studyDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('${texts.studyPlanTitle} ${widget.subject}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: texts.viewSchedule,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyStudyScreen(studentId: widget.studentId),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${texts.dayNumber} ${currentDayIndex + 1} ($readableDate)'),
            const SizedBox(height: 12),
            TextField(
              controller: hourControllers[currentDayIndex],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: texts.howManyHours,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextOrFinish,
              child: Text(currentDayIndex < widget.availableDays - 1 ? texts.next : texts.finishPlan),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
