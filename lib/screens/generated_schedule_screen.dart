import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneratedScheduleScreen extends StatefulWidget {
  final String studentId;
  const GeneratedScheduleScreen({super.key, required this.studentId});

  @override
  State<GeneratedScheduleScreen> createState() => _GeneratedScheduleScreenState();
}

class _GeneratedScheduleScreenState extends State<GeneratedScheduleScreen> {
  Map<String, List<String>> schedule = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateSchedule();
  }

  Future<void> generateSchedule() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final studentData = snapshot.docs.first.data();
    final exams = List<Map<String, dynamic>>.from(studentData['exams'] ?? []);
    final studyHours = Map<String, dynamic>.from(studentData['study_hours'] ?? {});

    exams.sort((a, b) {
      final aDate = (a['date'] as Timestamp).toDate();
      final bDate = (b['date'] as Timestamp).toDate();
      return aDate.compareTo(bDate);
    });

    final daysOfWeek = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
    schedule = {for (var day in daysOfWeek) day: []};

    for (var exam in exams) {
      final subject = exam['subject'];
      final examDate = (exam['date'] as Timestamp).toDate();

      for (var day in daysOfWeek) {
        final today = DateTime.now();
        final currentDayIndex = today.weekday % 7;
        final targetDayIndex = daysOfWeek.indexOf(day);

        final dateOfThisDay = today.add(Duration(days: (targetDayIndex - currentDayIndex + 7) % 7));
        if (dateOfThisDay.isAfter(examDate)) continue;

        int hours = studyHours[day]?.toInt() ?? 0;
        for (int i = 0; i < hours; i++) {
          schedule[day]?.add(subject);
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الجدول الدراسي')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: schedule.keys.length,
        itemBuilder: (context, index) {
          final day = schedule.keys.elementAt(index);
          final items = schedule[day]!;

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...items.map((subject) => Text("📘 $subject")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}