import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io' show Platform;

class NotificationsHelper {
  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('🚫 الإشعارات غير مدعومة على هذا النظام');
      return;
    }

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'exam_channel',
          channelName: 'Exam Notifications',
          channelDescription: 'Notifications for upcoming exams',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
        )
      ],
    );

    print('✅ AwesomeNotifications initialized');
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('🚫 إشعارات غير مدعومة على هذا النظام');
      return;
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      print("❌ التاريخ المحدد للإشعار ماضي: $scheduledDate");
      return;
    }

    print("✅ إشعار مجدول: $title عند $scheduledDate");

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduledDate.millisecondsSinceEpoch ~/ 1000,
        channelKey: 'exam_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        allowWhileIdle: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }

  static Future<void> scheduleYearlyNotifications() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('🚫 إشعارات غير مدعومة على هذا النظام');
      return;
    }

    final now = DateTime.now();
    final year = now.year;

    final List<Map<String, dynamic>> yearlyNotifications = [
      {
        'date': DateTime(year, 1, 10, 12, 0),
        'title': '📚 الامتحانات الشهرية عالبواب',
        'body': 'اجا وقت الدراسة! لا تنسى تفوت تواريخ امتحانك',
      },
      {
        'date': DateTime(year, 1, 12, 12, 0),
        'title': '🎯 الامتحانات الفصلية قربت!',
        'body': 'اجا الجد! لا تنسى تفوت تواريخ امتحاناتك',
      },
      {
        'date': DateTime(year, 1, 4, 12, 0),
        'title': '📚 الامتحانات الشهرية عالبواب',
        'body': 'اجا وقت الدراسة! لا تنسى تفوت تواريخ امتحانك',
      },
      {
        'date': DateTime(year, 1, 6, 12, 0),
        'title': '🌞 قربت العطلة!',
        'body': 'بعرف تعبان بس مظلش اشي! فوت تواريخ امتحاناتك الفصلية',
      },
    ];

    for (var n in yearlyNotifications) {
      final scheduledDate = n['date'];
      if (scheduledDate.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: scheduledDate.millisecondsSinceEpoch ~/ 1000,
            channelKey: 'exam_channel',
            title: n['title'],
            body: n['body'],
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: scheduledDate.year,
            month: scheduledDate.month,
            day: scheduledDate.day,
            hour: scheduledDate.hour,
            minute: scheduledDate.minute,
            second: 0,
            timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
            repeats: true,
          ),
        );
        print("✅ إشعار سنوي مجدول: ${n['title']} على ${scheduledDate.toLocal()}");
      }
    }
  }
}
