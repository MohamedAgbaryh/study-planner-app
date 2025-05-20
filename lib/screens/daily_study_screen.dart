import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyStudyScreen extends StatefulWidget {
  final String studentId;

  const DailyStudyScreen({super.key, required this.studentId});

  @override
  State<DailyStudyScreen> createState() => _DailyStudyScreenState();
}

class _DailyStudyScreenState extends State<DailyStudyScreen> {
  List<Map<String, dynamic>> todaySessions = [];
  bool isMarkedDone = false;

  @override
  void initState() {
    super.initState();
    fetchTodaySessions();
    checkDailyMark();
  }

  Future<void> fetchTodaySessions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final sessions = List<Map<String, dynamic>>.from(data['study_sessions'] ?? []);
      final now = DateTime.now();

      setState(() {
        todaySessions = sessions.where((s) {
          final start = (s['start'] as Timestamp).toDate();
          return start.year == now.year &&
              start.month == now.month &&
              start.day == now.day;
        }).toList();
      });
    }
  }

  Future<void> checkDailyMark() async {
    final now = DateTime.now();
    final formatted = "${now.year}-${now.month}-${now.day}";

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final checks = data['daily_checks'] ?? {};
      setState(() {
        isMarkedDone = checks[formatted] == true;
      });
    }
  }

  Future<void> markDone() async {
    final now = DateTime.now();
    final formatted = "${now.year}-${now.month}-${now.day}";

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('students').doc(docId).update({
        'daily_checks.$formatted': true,
      });

      setState(() {
        isMarkedDone = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ أحسنت! تم وضع علامة الإنجاز لليوم.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جلسات اليوم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (todaySessions.isEmpty)
              const Center(child: Text('لا يوجد جلسات لهذا اليوم'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: todaySessions.length,
                  itemBuilder: (context, index) {
                    final session = todaySessions[index];
                    final start = (session['start'] as Timestamp).toDate();
                    return ListTile(
                      title: Text(session['subject']),
                      subtitle: Text(
                        '${session['type'] == 'study' ? "دراسة" : "استراحة"} في ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isMarkedDone ? null : markDone,
              child: const Text('✅ وضعت علامة إنجاز اليوم'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
