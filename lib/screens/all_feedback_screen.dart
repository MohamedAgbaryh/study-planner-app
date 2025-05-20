import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';
import 'single_feedback_screen.dart';

class AllFeedbackScreen extends StatefulWidget {
  final String? studentId;
  final String? fullName;

  const AllFeedbackScreen({super.key, this.studentId, this.fullName});

  @override
  State<AllFeedbackScreen> createState() => _AllFeedbackScreenState();
}

class _AllFeedbackScreenState extends State<AllFeedbackScreen> {
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedFeedbacks = {};

  @override
  void initState() {
    super.initState();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    Query query = FirebaseFirestore.instance.collection('feedback');

    if (widget.studentId != null) {
      query = query.where('student_id', isEqualTo: widget.studentId!);
    }

    query = query.orderBy('timestamp', descending: true);

    final snapshot = await query.get();
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final studentName = widget.fullName ?? data['student_name'] ?? 'غير معروف';
      grouped.putIfAbsent(studentName, () => []);
      grouped[studentName]!.add({
        'message': data['message'],
        'timestamp': data['timestamp'],
      });
    }

    setState(() {
      groupedFeedbacks = grouped;
      isLoading = false;
    });
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
              // ✅ عنوان وزر رجوع
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.fullName != null
                            ? '${texts.allFeedbackFrom} ${widget.fullName}'
                            : texts.allFeedbackTitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : groupedFeedbacks.isEmpty
                    ? Center(
                  child: Text(
                    texts.noFeedbackYet,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                )
                    : ListView.builder(
                  itemCount: groupedFeedbacks.length,
                  itemBuilder: (context, index) {
                    final studentName = groupedFeedbacks.keys.elementAt(index);
                    final feedbacks = groupedFeedbacks[studentName]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ExpansionTile(
                          initiallyExpanded: widget.studentId != null,
                          title: Text(
                            studentName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: feedbacks.map((f) {
                            final formattedDate = formatDate(f['timestamp']);
                            return ListTile(
                              title: Text(
                                f['message'],
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                              subtitle: Text(
                                '${texts.date}: $formattedDate',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SingleFeedbackScreen(
                                      studentName: studentName,
                                      message: f['message'],
                                      timestamp: f['timestamp'],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
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
