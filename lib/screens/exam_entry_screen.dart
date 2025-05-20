import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exam_plan_screen.dart';

class ExamEntryScreen extends StatefulWidget {
  final String studentId;
  final String fullName;

  const ExamEntryScreen({super.key, required this.studentId, required this.fullName});

  @override
  State<ExamEntryScreen> createState() => _ExamEntryScreenState();
}

class _ExamEntryScreenState extends State<ExamEntryScreen> {
  final TextEditingController subjectController = TextEditingController();
  DateTime? selectedDate;
  bool withBreaks = false;

  Future<List<DateTime>> _getExistingExamDates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isEmpty) return [];

    final data = snapshot.docs.first.data();
    final exams = List<Map<String, dynamic>>.from(data['exams'] ?? []);

    return exams.map((e) => (e['date'] as Timestamp).toDate()).toList();
  }

  int _calculateAvailableDays(DateTime examDate, List<DateTime> existingDates) {
    final today = DateTime.now();
    int maxDays = examDate.difference(today).inDays;

    for (DateTime d in existingDates) {
      int diff = d.difference(examDate).inDays.abs();
      if (diff > 0 && diff < maxDays) {
        maxDays = diff;
      }
    }

    if (maxDays >= 3) return 3;
    if (maxDays == 2) return 2;
    return 1;
  }

  void _proceedToPlan() async {
    if (subjectController.text.trim().isEmpty || selectedDate == null) return;

    final existingDates = await _getExistingExamDates();
    int availableDays = _calculateAvailableDays(selectedDate!, existingDates);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamPlanScreen(
          subject: subjectController.text.trim(),
          examDate: selectedDate!,
          availableDays: availableDays,
          withBreaks: withBreaks,
          studentId: widget.studentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدخال امتحان جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'اسم المادة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null
                      ? 'لم يتم اختيار تاريخ'
                      : 'تاريخ الامتحان: ${selectedDate!.toLocal().toString().split(" ")[0]}'),
                ),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: const Text('اختيار التاريخ'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: withBreaks,
                  onChanged: (val) => setState(() => withBreaks = val ?? false),
                ),
                const Text('أفضل الدراسة مع استراحات')
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _proceedToPlan,
              child: const Text('التالي'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
