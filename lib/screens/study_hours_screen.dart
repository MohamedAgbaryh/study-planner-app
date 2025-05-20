import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'generated_schedule_screen.dart';

class StudyHoursScreen extends StatefulWidget {
  final String studentId;
  const StudyHoursScreen({super.key, required this.studentId});

  @override
  State<StudyHoursScreen> createState() => _StudyHoursScreenState();
}

class _StudyHoursScreenState extends State<StudyHoursScreen> {
  final Map<String, TextEditingController> controllers = {
    'السبت': TextEditingController(),
    'الأحد': TextEditingController(),
    'الاثنين': TextEditingController(),
    'الثلاثاء': TextEditingController(),
    'الأربعاء': TextEditingController(),
    'الخميس': TextEditingController(),
  };

  Future<void> _submitStudyHours() async {
    final Map<String, int> hoursPerDay = {};

    controllers.forEach((day, controller) {
      final value = int.tryParse(controller.text.trim()) ?? 0;
      if (value > 0) {
        hoursPerDay[day] = value;
      }
    });

    await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get()
        .then((snapshot) {
      final docId = snapshot.docs.first.id;
      FirebaseFirestore.instance.collection('students').doc(docId).update({
        'study_hours': hoursPerDay,
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedScheduleScreen(studentId: widget.studentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أوقات الدراسة المتاحة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: controllers.keys.map((day) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: controllers[day],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'عدد الساعات في $day',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _submitStudyHours,
              child: const Text('حفظ ومتابعة'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}