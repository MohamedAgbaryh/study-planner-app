import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_texts.dart';

class FeedbackScreen extends StatefulWidget {
  final String studentId;
  final String fullName;

  const FeedbackScreen({super.key, required this.studentId, required this.fullName});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  bool isSending = false;

  Future<void> sendFeedback() async {
    final message = feedbackController.text.trim();
    if (message.isEmpty) return;

    setState(() => isSending = true);

    await FirebaseFirestore.instance.collection('feedback').add({
      'student_id': widget.studentId,
      'student_name': widget.fullName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'unread',
    });

    setState(() {
      isSending = false;
      feedbackController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTexts.of(context).feedbackSentMessage)),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ زر رجوع وعنوان
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      texts.sendFeedback,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ✅ حقل الكتابة مع ديكور ناعم
                TextField(
                  controller: feedbackController,
                  maxLines: 6,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: texts.writeFeedbackHint,
                    hintStyle: const TextStyle(fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ زر إرسال بتصميم أنيق
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isSending ? null : sendFeedback,
                    icon: isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    label: Text(
                      isSending ? '' : texts.send,
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
