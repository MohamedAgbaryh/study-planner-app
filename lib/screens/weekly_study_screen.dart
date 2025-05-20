import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';

class WeeklyStudyScreen extends StatefulWidget {
  final String studentId;

  const WeeklyStudyScreen({super.key, required this.studentId});

  @override
  State<WeeklyStudyScreen> createState() => _WeeklyStudyScreenState();
}

class _WeeklyStudyScreenState extends State<WeeklyStudyScreen> {
  Map<String, List<Map<String, dynamic>>> sessionsByDay = {};
  List<Map<String, dynamic>> allSessions = [];
  bool isLoading = true;

  List<String> weekdays = [];

  @override
  void initState() {
    super.initState();
    fetchStudySessions();
  }

  void setLocalizedWeekdays(Locale locale) {
    weekdays = locale.languageCode == 'he'
        ? ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת']
        : ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  }

  Future<void> fetchStudySessions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('student_id', isEqualTo: widget.studentId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final sessions = List<Map<String, dynamic>>.from(data['study_sessions'] ?? []);

      allSessions = sessions;

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var session in sessions) {
        final DateTime date = (session['start'] as Timestamp).toDate();
        final String day = weekdays[date.weekday % 7];

        grouped.putIfAbsent(day, () => []);
        grouped[day]!.add(session);
      }

      for (var day in grouped.keys) {
        grouped[day]!.sort((a, b) =>
            (a['start'] as Timestamp).toDate().compareTo((b['start'] as Timestamp).toDate()));
      }

      setState(() {
        sessionsByDay = grouped;
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getClosestExamSubject(DateTime dayDate) {
    final examSessions = allSessions.where((s) => s['subject'] != null).toList();
    examSessions.sort((a, b) {
      final aDate = (a['start'] as Timestamp).toDate();
      final bDate = (b['start'] as Timestamp).toDate();
      return (aDate.difference(dayDate)).abs().compareTo((bDate.difference(dayDate)).abs());
    });

    if (examSessions.isNotEmpty) {
      return examSessions.first['subject'];
    } else {
      return '';
    }
  }

  void _showDaySessions(String day, List<Map<String, dynamic>> sessions, AppTexts texts) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${texts.dailyPlanTitle} $day',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sessions.map((s) {
                final time = (s['start'] as Timestamp).toDate();
                final type = s['type'] == 'study' ? texts.studySessionLabel : texts.breakSessionLabel;
                return ListTile(
                  title: Text(type, style: const TextStyle(fontFamily: 'Poppins')),
                  subtitle: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                  leading: Icon(
                    s['type'] == 'study' ? Icons.menu_book : Icons.coffee,
                    color: s['type'] == 'study' ? Colors.blueAccent : Colors.orangeAccent,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              texts.close,
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    setLocalizedWeekdays(Localizations.localeOf(context));

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
              // زر الرجوع والعنوان
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
                      texts.weeklyPlanTitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: weekdays.length,
                  itemBuilder: (context, index) {
                    final day = weekdays[index];
                    final sessions = sessionsByDay[day] ?? [];
                    final date = sessions.isNotEmpty
                        ? (sessions.first['start'] as Timestamp).toDate()
                        : null;
                    final subject = date != null ? _getClosestExamSubject(date) : '';

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          day,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${texts.taskCount}: ${sessions.length}',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            if (subject.isNotEmpty)
                              Text(
                                '${texts.exam}: $subject',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                            if (date != null)
                              Text(
                                '${texts.date}: ${_formatDate(date)}',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: sessions.isNotEmpty
                            ? () => _showDaySessions(day, sessions, texts)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
