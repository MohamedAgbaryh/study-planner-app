import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';
import 'feedback_screen.dart';

class FullScheduleScreen extends StatefulWidget {
  final String studentId;

  const FullScheduleScreen({super.key, required this.studentId});

  @override
  State<FullScheduleScreen> createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  Map<String, List<Map<String, dynamic>>> sessionsByDay = {};
  bool isLoading = true;
  String? selectedDay;
  String studentFullName = '';

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final now = DateTime.now();

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      studentFullName = data['full_name'] ?? '';
      final List<dynamic> sessions = data['study_sessions'] ?? [];
      final List<dynamic> exams = data['exams'] ?? [];

      // الحصول على تواريخ الامتحانات الفعليّة
      final Set<String> validExamSubjects = exams
          .where((exam) {
        final examDate = (exam['date'] as Timestamp).toDate();
        return examDate.isAfter(now) || _isSameDay(examDate, now);
      })
          .map((e) => e['subject'] as String)
          .toSet();

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var session in sessions) {
        final DateTime start = (session['start'] as Timestamp).toDate();
        if ((start.isAfter(now) || _isSameDay(start, now)) &&
            validExamSubjects.contains(session['subject'])) {
          String dayKey = "${start.day}/${start.month}/${start.year}";

          if (!grouped.containsKey(dayKey)) {
            grouped[dayKey] = [];
          }

          grouped[dayKey]!.add({
            'start': start,
            'end': session['end'] != null
                ? (session['end'] as Timestamp?)?.toDate()
                : null,
            'subject': session['subject'],
            'type': session['type'],
            'label': session['label'],
          });

          grouped[dayKey]!.sort(
                  (a, b) => (a['start'] as DateTime).compareTo(b['start'] as DateTime));
        }
      }

      // ترتيب الأيام حسب التاريخ
      final sortedKeys = grouped.keys.toList()
        ..sort((a, b) {
          DateTime da = _parseDateKey(a);
          DateTime db = _parseDateKey(b);
          return da.compareTo(db);
        });

      final sortedMap = {
        for (var k in sortedKeys) k: grouped[k]!,
      };

      setState(() {
        sessionsByDay = sortedMap;
        isLoading = false;
        if (sortedMap.isNotEmpty) {
          selectedDay = sortedMap.keys.first;
        }
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _parseDateKey(String key) {
    final parts = key.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    final selectedSessions = selectedDay != null
        ? sessionsByDay[selectedDay!] ?? []
        : [];

    return Scaffold(
      appBar: AppBar(title: Text(texts.fullScheduleTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessionsByDay.isEmpty
          ? Center(child: Text(texts.noSessionsFound))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.chooseDayToView,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedDay,
              isExpanded: true,
              hint: Text(texts.chooseDay),
              items: sessionsByDay.keys.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedDay = val;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedSessions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: selectedSessions.length,
                  itemBuilder: (context, index) {
                    final session = selectedSessions[index];
                    final start = session['start'] as DateTime;
                    final label = session['label'];

                    String timeLabel = label ??
                        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

                    return Card(
                      margin:
                      const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: session['type'] == 'study'
                            ? const Icon(Icons.book,
                            color: Colors.blue)
                            : const Icon(Icons.coffee,
                            color: Colors.brown),
                        title: Text(session['subject'] ?? ''),
                        subtitle: Text(timeLabel),
                      ),
                    );
                  },
                ),
              )
            else
              Text(texts.noSessionsForDay),
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
                fullName: studentFullName,
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
