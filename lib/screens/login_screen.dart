import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exam_screen.dart';
import '../widgets/gradient_scaffold.dart';
import '../main.dart';
import '../app_texts.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController idController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool inputsValid = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    idController.addListener(validateInputs);
    codeController.addListener(validateInputs);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  void validateInputs() {
    final valid = idController.text.trim().isNotEmpty &&
        codeController.text.trim().isNotEmpty;
    if (inputsValid != valid) {
      setState(() {
        inputsValid = valid;
      });
    }
  }

  Future<void> loginStudent() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String enteredId = idController.text.trim();
      String enteredCode = codeController.text.trim();

      final studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('student_id', isEqualTo: enteredId)
          .where('access_code', isEqualTo: enteredCode)
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        final userData = studentSnapshot.docs.first.data();
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                ExamScheduleScreen(
                  studentId: enteredId,
                  fullName: userData['full_name'] ?? '',
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      } else {
        final adminSnapshot = await FirebaseFirestore.instance
            .collection('admins')
            .where('admin_id', isEqualTo: enteredId)
            .where('access_code', isEqualTo: enteredCode)
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminScreen()),
          );
        } else {
          _shakeController.forward(from: 0); // ✅ شغل الاهتزاز
          setState(() {
            errorMessage = AppTexts.of(context).invalidLogin;
          });
        }
      }
    } catch (e) {
      print('🔥 Firebase Login Error: $e');
      setState(() {
        errorMessage = AppTexts.of(context).errorOccurred;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    idController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(texts.loginTitle),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (String value) {
              if (value == 'ar') {
                MyApp.setLocale(context, const Locale('ar'));
              } else if (value == 'he') {
                MyApp.setLocale(context, const Locale('he'));
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'ar', child: Text('العربية')),
              const PopupMenuItem(value: 'he', child: Text('עברית')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final dx = sin(_shakeAnimation.value * pi * 2 / 100) * 8;
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 20),
                TextField(
                  controller: idController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: texts.studentId,
                    prefixIcon: const Icon(Icons.perm_identity),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: texts.accessCode,
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: inputsValid ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedScale(
                    scale: inputsValid ? 1.0 : 0.95,
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton.icon(
                      onPressed: (inputsValid && !isLoading) ? loginStudent : null,
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.login),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Text(
                          texts.loginButton,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.deepPurple.withOpacity(0.3),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
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
