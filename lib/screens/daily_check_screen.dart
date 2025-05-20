import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyCheckScreen extends StatefulWidget {
  final String studentId;
  final DateTime date;

  const DailyCheckScreen({super.key, required this.studentId, required this.date});

  @override
  State<DailyCheckScreen> createState() => _DailyCheckScreenState();
}

class _DailyCheckScreenState extends State<DailyCheckScreen> {
  bool isChecked = false;
  bool isSubmitted = false;

  Future<void> _submitCheck() async {
    final formattedDate = "${widget.date.year}-${widget.date.month}-${widget.date.day}";

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('students')
          .doc(docId)
          .set({
        'daily_checks': {
          formattedDate: true
        }
      }, SetOptions(merge: true));

      setState(() {
        isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readableDate = "${widget.date.day}/${widget.date.month}/${widget.date.year}";

    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد إنجاز اليوم')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("هل أنهيت دراستك اليوم؟ ($readableDate)", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('نعم، أنهيت كل المهام الدراسية ✅'),
              value: isChecked,
              onChanged: isSubmitted
                  ? null
                  : (val) {
                setState(() {
                  isChecked = val ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isChecked && !isSubmitted ? _submitCheck : null,
              child: Text(isSubmitted ? '✔️ تم الحفظ' : 'حفظ التقدم'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

