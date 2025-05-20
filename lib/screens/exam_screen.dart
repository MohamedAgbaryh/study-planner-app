import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'study_preference_screen.dart';
import 'full_schedule_screen.dart';
import 'feedback_screen.dart';
import 'edit_schedule_screen.dart';
import '../app_texts.dart';
import 'package:intl/intl.dart';

class ExamScheduleScreen extends StatefulWidget {
  final String studentId;
  final String fullName;

  const ExamScheduleScreen({super.key, required this.studentId, required this.fullName});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  final TextEditingController subjectController = TextEditingController();
  DateTime? selectedDate;
  List<DateTime> disabledDates = [];
  DateTime today = DateTime.now();
  DateTime? nearestExam;

  @override
  void initState() {
    super.initState();
    _loadDisabledDates();
  }

  Future<void> _loadDisabledDates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final exams = List<Map<String, dynamic>>.from(data['exams'] ?? []);
      List<DateTime> futureExams = exams
          .map((e) => (e['date'] as Timestamp).toDate())
          .where((d) => !d.isBefore(today))
          .toList();
      futureExams.sort();
      setState(() {
        disabledDates = futureExams;
        nearestExam = futureExams.isNotEmpty ? futureExams.first : null;
      });
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    DateTime initial = now;

    while (disabledDates.any((d) => d.year == initial.year && d.month == initial.month && d.day == initial.day)) {
      initial = initial.add(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: (date) {
        return !disabledDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.indigo),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _goToPreferences() async {
    final subject = subjectController.text.trim();
    if (subject.isEmpty || selectedDate == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      final data = snapshot.docs.first.data();
      final exams = List<Map<String, dynamic>>.from(data['exams'] ?? []);

      final alreadyExists = exams.any((exam) =>
      exam['subject'] == subject ||
          (exam['date'] as Timestamp).toDate().difference(selectedDate!).inDays == 0);

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.of(context).examExistsWarning)),
        );
        return;
      }

      exams.add({
        'subject': subject,
        'date': Timestamp.fromDate(selectedDate!),
      });

      await FirebaseFirestore.instance.collection('students').doc(docId).update({'exams': exams});
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudyPreferenceScreen(
          studentId: widget.studentId,
          subject: subject,
          examDate: selectedDate!,
          availableDays: _calculateAvailableDays(selectedDate!, disabledDates),
        ),
      ),
    );
  }

  int _calculateAvailableDays(DateTime selectedDate, List<DateTime> otherExams) {
    final today = DateTime.now();
    int daysUntilExam = selectedDate.difference(today).inDays;
    if (daysUntilExam < 1) return 1;

    int maxDays = daysUntilExam.clamp(1, 3);

    for (var examDate in otherExams) {
      int diff = examDate.difference(selectedDate).inDays.abs();
      if (diff > 0 && diff < maxDays) {
        maxDays = diff;
      }
    }

    return maxDays;
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.examScheduleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'تعديل المواعيد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditScheduleScreen(studentId: widget.studentId),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${texts.welcome} ${widget.fullName} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (nearestExam != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${texts.upcomingExam}: ${DateFormat('yyyy-MM-dd').format(nearestExam!)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: texts.subjectName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? texts.noDateSelected
                        : '${texts.selectedExamDate}: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(texts.selectDate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _goToPreferences,
              child: Text(texts.addExam),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScheduleScreen(studentId: widget.studentId),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, color: Colors.white, size: 24),
              label: Text(
                texts.viewSchedule,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeedbackScreen(
                studentId: widget.studentId,
                fullName: widget.fullName,
              ),
            ),
          );
        },
        icon: const Icon(Icons.feedback_outlined),
        label: Text(texts.sendFeedback),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
