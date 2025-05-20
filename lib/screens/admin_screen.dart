import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';
import 'all_feedback_screen.dart';
import 'single_feedback_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    final studentsSnapshot = await FirebaseFirestore.instance.collection('students').get();
    List<Map<String, dynamic>> loaded = [];

    for (var doc in studentsSnapshot.docs) {
      final data = doc.data();
      final feedbacksSnapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('student_id', isEqualTo: data['student_id'])
          .orderBy('timestamp', descending: true)
          .get();

      final allFeedbacks = feedbacksSnapshot.docs;
      final latestFeedback = allFeedbacks.isNotEmpty ? allFeedbacks.first.data()['message'] : '-';
      final unreadCount = allFeedbacks.where((f) => f['status'] == 'unread').length;

      loaded.add({
        'full_name': data['full_name'],
        'student_id': data['student_id'],
        'exam_count': (data['exams'] as List?)?.length ?? 0,
        'latest_feedback': latestFeedback,
        'unread_count': unreadCount,
      });
    }

    setState(() {
      students = loaded;
      isLoading = false;
    });
  }

  void showLatestFeedback(String studentId, String fullName) async {
    final texts = AppTexts.of(context);

    final snapshot = await FirebaseFirestore.instance
        .collection('feedback')
        .where('student_id', isEqualTo: studentId)
        .where('status', isEqualTo: 'unread')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    final feedbacks = snapshot.docs;

    if (feedbacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts.noNewFeedback)),
      );
      return;
    }

    final feedback = feedbacks.first;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SingleFeedbackScreen(
          studentName: fullName,
          message: feedback['message'] ?? '-',
          timestamp: feedback['timestamp'],
          onMarkAsRead: () async {
            await FirebaseFirestore.instance
                .collection('feedback')
                .doc(feedback.id)
                .update({'status': 'read'});
          },
        ),
      ),
    );

    fetchStudentData();
  }

  void showAllFeedback(String studentId, String fullName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllFeedbackScreen(
          studentId: studentId,
          fullName: fullName,
        ),
      ),
    );
  }

  void showAddStudentDialog() {
    final texts = AppTexts.of(context);
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(texts.addStudent),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: texts.studentName),
            ),
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: texts.studentId),
            ),
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: texts.accessCode),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance.collection('students').add({
                'full_name': nameController.text.trim(),
                'student_id': idController.text.trim(),
                'access_code': codeController.text.trim(),
                'exams': [],
                'study_sessions': [],
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(texts.studentAdded)),
              );
              fetchStudentData();
            },
            child: Text(texts.confirm),
          ),
        ],
      ),
    );
  }

  void showDeleteStudentDialog() {
    final texts = AppTexts.of(context);
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(texts.deleteStudent),
        content: TextField(
          controller: idController,
          decoration: InputDecoration(labelText: texts.enterStudentIdToDelete),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final studentId = idController.text.trim();

              // 🔍 البحث عن وثيقة الطالب
              final studentSnapshot = await FirebaseFirestore.instance
                  .collection('students')
                  .where('student_id', isEqualTo: studentId)
                  .get();

              if (studentSnapshot.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(texts.studentNotFound)),
                );
                return;
              }

              // ✅ حذف وثائق الطالب من students
              for (var doc in studentSnapshot.docs) {
                await FirebaseFirestore.instance.collection('students').doc(doc.id).delete();
              }

              // ✅ حذف جميع feedback الخاصة بالطالب
              final feedbackSnapshot = await FirebaseFirestore.instance
                  .collection('feedback')
                  .where('student_id', isEqualTo: studentId)
                  .get();

              for (var doc in feedbackSnapshot.docs) {
                await FirebaseFirestore.instance.collection('feedback').doc(doc.id).delete();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(texts.studentDeleted)),
              );

              // 🔄 تحديث القائمة بعد الحذف
              fetchStudentData();
            },
            child: Text(texts.confirm),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.adminPanelTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            tooltip: texts.allFeedback,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllFeedbackScreen()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showAddStudentDialog,
                    icon: const Icon(Icons.person_add),
                    label: Text(texts.addStudent),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: showDeleteStudentDialog,
                    icon: const Icon(Icons.person_remove),
                    label: Text(texts.deleteStudent),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                student['full_name'],
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 20, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text('${texts.studentId}: ${student['student_id']}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, size: 20, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text('${texts.examCount}: ${student['exam_count']}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.chat_outlined, size: 20, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${texts.latestFeedback}: ${student['latest_feedback']}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (student['unread_count'] > 0)
                              ElevatedButton.icon(
                                onPressed: () => showLatestFeedback(
                                  student['student_id'],
                                  student['full_name'],
                                ),
                                icon: const Icon(Icons.mark_email_unread_outlined),
                                label: Text('(${student['unread_count']}) ${texts.feedback}'),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    texts.noNewFeedback,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            OutlinedButton.icon(
                              onPressed: () => showAllFeedback(
                                student['student_id'],
                                student['full_name'],
                              ),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: Text(texts.allFeedback),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
