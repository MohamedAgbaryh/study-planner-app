import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';
import 'study_preference_screen.dart';

class EditScheduleScreen extends StatefulWidget {
  final String studentId;
  const EditScheduleScreen({super.key, required this.studentId});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  List<Map<String, dynamic>> exams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExams();
  }

  Future<void> loadExams() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final data = snapshot.docs.first.data();
    exams = List<Map<String, dynamic>>.from(data['exams'] ?? []);

    exams.sort((a, b) {
      final dateA = (a['date'] is Timestamp) ? a['date'].toDate() : a['date'];
      final dateB = (b['date'] is Timestamp) ? b['date'].toDate() : b['date'];
      return dateA.compareTo(dateB);
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveExams() async {
    final updated = exams.map((e) {
      final date = (e['date'] is Timestamp) ? e['date'].toDate() : e['date'];
      return {
        'subject': e['subject'],
        'date': Timestamp.fromDate(date),
      };
    }).toList();

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    final docId = snapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection('students')
        .doc(docId)
        .update({'exams': updated});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTexts.of(context).examAddedSuccessfully)),
    );
  }

  void _editDate(int index) async {
    final current = (exams[index]['date'] is Timestamp)
        ? exams[index]['date'].toDate()
        : exams[index]['date'];

    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      selectableDayPredicate: (date) {
        return !exams.any((e) =>
        e != exams[index] &&
            ((e['date'] is Timestamp ? e['date'].toDate() : e['date'])
                .difference(date)
                .inDays ==
                0));
      },
    );

    if (picked != null) {
      final subject = exams[index]['subject'];

      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('student_id', isEqualTo: widget.studentId)
          .get();

      final docId = snapshot.docs.first.id;
      final docRef =
      FirebaseFirestore.instance.collection('students').doc(docId);

      final docData = snapshot.docs.first.data();
      final allSessions =
      List<Map<String, dynamic>>.from(docData['study_sessions'] ?? []);
      final updatedSessions =
      allSessions.where((s) => s['subject'] != subject).toList();

      await docRef.update({'study_sessions': updatedSessions});

      exams[index]['date'] = picked;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudyPreferenceScreen(
            studentId: widget.studentId,
            subject: subject,
            examDate: picked,
            availableDays: 3,
          ),
        ),
      );
    }
  }

  Future<void> _deleteExam(int index) async {
    final subject = exams[index]['subject'];
    exams.removeAt(index);
    setState(() {});

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    final docId = snapshot.docs.first.id;
    final docRef = FirebaseFirestore.instance.collection('students').doc(docId);

    await docRef.update({'exams': exams});

    final docData = snapshot.docs.first.data();
    final allSessions =
    List<Map<String, dynamic>>.from(docData['study_sessions'] ?? []);
    final updatedSessions =
    allSessions.where((s) => s['subject'] != subject).toList();

    await docRef.update({'study_sessions': updatedSessions});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTexts.of(context).examDeletedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ عنوان مع زر رجوع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      texts.fullScheduleTitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    final date = (exam['date'] is Timestamp)
                        ? exam['date'].toDate()
                        : exam['date'];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          exam['subject'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          '${texts.date}: ${date.toLocal().toString().split(" ")[0]}',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.indigo),
                              onPressed: () => _editDate(index),
                              tooltip: texts.selectDate,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _deleteExam(index),
                              tooltip: texts.close,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: saveExams,
                  icon: const Icon(Icons.save),
                  label: Text(
                    texts.finishPlan,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
