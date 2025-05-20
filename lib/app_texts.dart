import 'package:flutter/material.dart';

class AppTexts {
  final Locale locale;

  AppTexts(this.locale);

  static AppTexts of(BuildContext context) {
    return AppTexts(Localizations.localeOf(context));
  }

  String get loginTitle => locale.languageCode == 'he' ? 'התחברות' : 'تسجيل الدخول';
  String get studentId => locale.languageCode == 'he' ? 'מספר זהות' : 'رقم الهوية';
  String get accessCode => locale.languageCode == 'he' ? 'קוד גישה' : 'الكود الخاص';
  String get loginButton => locale.languageCode == 'he' ? 'התחבר' : 'تسجيل الدخول';
  String get invalidLogin => locale.languageCode == 'he' ? 'מספר זהות או קוד שגוי.' : 'رقم الهوية أو الكود غير صحيح.';
  String get errorOccurred => locale.languageCode == 'he' ? 'אירעה שגיאה, נסה שוב.' : 'حدث خطأ، حاول مرة أخرى.';
  String get examScheduleTitle => locale.languageCode == 'he' ? 'לוח מבחנים' : 'مواعيد الامتحانات';
  String get welcome => locale.languageCode == 'he' ? 'ברוך הבא' : 'مرحبًا';
  String get subjectName => locale.languageCode == 'he' ? 'שם המקצוע' : 'اسم المادة';
  String get noDateSelected => locale.languageCode == 'he' ? 'לא נבחר תאריך' : 'لم يتم اختيار تاريخ';
  String get selectedExamDate => locale.languageCode == 'he' ? 'תאריך הבחינה' : 'تاريخ الامتحان';
  String get selectDate => locale.languageCode == 'he' ? 'בחר תאריך' : 'اختيار التاريخ';
  String get addExam => locale.languageCode == 'he' ? 'הוסף מבחן' : 'إضافة الامتحان';
  String get viewSchedule => locale.languageCode == 'he' ? 'הצג לוח לימודים' : 'مشاهدة جدولي الدراسي';
  String get examExistsWarning => locale.languageCode == 'he' ? '⚠️ המקצוע או התאריך כבר קיימים' : '⚠️ هذه المادة أو التاريخ موجود مسبقًا';
  String get studyPreferencesTitle => locale.languageCode == 'he' ? 'העדפות למידה' : 'تفضيلات الدراسة';
  String get studyWithBreaksQuestion => locale.languageCode == 'he' ? 'האם אתה מעדיף ללמוד עם הפסקות?' : 'هل تفضل الدراسة مع استراحات؟';
  String get optionWithBreaks => locale.languageCode == 'he' ? 'כן, אני רוצה הפסקה כל שעה' : 'نعم، أريد استراحة كل ساعة';
  String get optionWithoutBreaks => locale.languageCode == 'he' ? 'לא, אני מעדיף ללמוד ברצף' : 'لا، أريد الدراسة بشكل متواصل';
  String get continueButton => locale.languageCode == 'he' ? 'המשך' : 'متابعة';
  String get choosePreferenceWarning => locale.languageCode == 'he' ? 'אנא בחר אחת מהאפשרויות' : 'يرجى اختيار أحد الخيارين';
  String get studyPlanTitle => locale.languageCode == 'he' ? 'תוכנית לימוד עבור' : 'خطة مذاكرة';
  String get dayNumber => locale.languageCode == 'he' ? 'יום מספר' : 'اليوم رقم';
  String get howManyHours => locale.languageCode == 'he' ? 'כמה שעות תלמד היום?' : 'كم ساعة يمكنك الدراسة اليوم؟';
  String get next => locale.languageCode == 'he' ? 'הבא' : 'التالي';
  String get finishPlan => locale.languageCode == 'he' ? 'סיים תוכנית' : 'إنهاء الخطة';
  String get invalidHourRange => locale.languageCode == 'he'
      ? 'מספר השעות חייב להיות בין 1 ל-6'
      : 'عدد الساعات يجب أن يكون بين 1 و 6';
  String get weeklyPlanTitle => locale.languageCode == 'he' ? 'תוכנית לימודים שבועית' : 'خطة الأسبوع الدراسية';
  String get dailyPlanTitle => locale.languageCode == 'he' ? 'תוכנית ליום' : 'خطة يوم';
  String get studySessionLabel => locale.languageCode == 'he' ? '📚 לימוד' : '📚 دراسة';
  String get breakSessionLabel => locale.languageCode == 'he' ? '☕ הפסקה' : '☕ استراحة';
  String get close => locale.languageCode == 'he' ? 'סגור' : 'إغلاق';
  String get taskCount => locale.languageCode == 'he' ? 'מספר משימות' : 'عدد المهام';
  String get fullScheduleTitle => locale.languageCode == 'he' ? 'לוח לימודים מלא' : '📅 جدولي الدراسي';
  String get noSessionsFound => locale.languageCode == 'he' ? 'אין עדיין מפגשי לימוד' : 'لا توجد جلسات دراسية بعد';
  String get chooseDayToView => locale.languageCode == 'he' ? 'בחר יום לצפייה בפרטים:' : 'اختر اليوم لرؤية التفاصيل:';
  String get chooseDay => locale.languageCode == 'he' ? 'בחר יום' : 'اختر يومًا';
  String get noSessionsForDay => locale.languageCode == 'he' ? 'אין מפגשים ליום זה' : 'لا توجد جلسات مسجلة لهذا اليوم';
  String get sendFeedback => locale.languageCode == 'he' ? 'שלח משוב' : 'إرسال ملاحظة';
  String get writeFeedbackHint => locale.languageCode == 'he' ? 'כתוב את ההערה שלך כאן...' : 'اكتب ملاحظتك هنا...';
  String get send => locale.languageCode == 'he' ? 'שלח' : 'إرسال';
  String get feedbackSentMessage => locale.languageCode == 'he'
      ? 'המשוב נשלח בהצלחה'
      : 'تم إرسال الملاحظة بنجاح';
  String get adminPanelTitle => locale.languageCode == 'he' ? 'לוח ניהול' : 'لوحة تحكم الأدمن';
  String get examCount => locale.languageCode == 'he' ? 'מספר מבחנים' : 'عدد الامتحانات';
  String get latestFeedback => locale.languageCode == 'he' ? 'הערה אחרונה' : 'آخر ملاحظة';
  String get feedback => locale.languageCode == 'he' ? 'משוב' : 'ملاحظة';
  String get feedbackFrom => locale.languageCode == 'he' ? 'משוב מ' : 'ملاحظات من';
  String get noNewFeedback => locale.languageCode == 'he' ? 'אין משובים חדשים לתלמיד הזה' : 'لا توجد ملاحظات جديدة لهذا الطالب';
  String get adminLoginTitle => locale.languageCode == 'he' ? 'כניסת מנהל' : 'تسجيل دخول المدير';
  String get adminId => locale.languageCode == 'he' ? 'תעודת זהות מנהל' : 'رقم هوية المدير';
  String get login => locale.languageCode == 'he' ? 'התחברות' : 'تسجيل الدخول';
  String get invalidCredentials => locale.languageCode == 'he' ? 'תעודה או קוד שגויים.' : 'الهوية أو الكود غير صحيح.';
  String get loginError => locale.languageCode == 'he' ? 'אירעה שגיאה במהלך ההתחברות.' : 'حدث خطأ أثناء تسجيل الدخول.';
  String get allFeedbackFrom => locale.languageCode == 'he' ? 'כל המשובים מ' : 'جميع الملاحظات من';
  String get allFeedback => locale.languageCode == 'he' ? 'כל ההערות' : 'جميع الملاحظات';
  String get markAsRead => locale.languageCode == 'he' ? 'סמן כנקרא' : 'تمت قراءته';
  String get back => locale.languageCode == 'he' ? 'חזור' : 'رجوع';
  String get singleFeedbackTitle => locale.languageCode == 'he' ? 'הערה מפורטת' : 'ملاحظة مفصلة';
  String get studentName => locale.languageCode == 'he' ? 'שם התלמיד' : 'اسم الطالب';
  String get date => locale.languageCode == 'he' ? 'תאריך' : 'التاريخ';
  String get allFeedbackTitle => locale.languageCode == 'he' ? 'כל ההערות' : '📋 جميع الملاحظات';
  String get noFeedbackYet => locale.languageCode == 'he' ? 'אין הערות עדיין' : 'لا توجد ملاحظات بعد.';
  String get examAddedSuccessfully => locale.languageCode == 'he'
      ? 'המבחן נוסף בהצלחה!'
      : 'تمت إضافة الامتحان بنجاح!';
  String get nearestExam => locale.languageCode == 'he' ? 'המבחן הקרוב שלך בתאריך:' : 'أقرب امتحان لك بتاريخ:';
  String get upcomingExam => locale.languageCode == 'he'
      ? 'המבחן הקרוב שלך'
      : 'أقرب امتحان لديك';
  String get examDeletedSuccessfully => locale.languageCode == 'he'
      ? 'הבחינה נמחקה בהצלחה עם כל המפגשים שלה'
      : 'تم حذف الامتحان وجميع جلساته بنجاح';
  String get examUpdatedSuccessfully => locale.languageCode == 'he'
      ? 'המבחן עודכן בהצלחה'
      : 'تم تحديث الامتحان بنجاح';
  // ✅ ترجمة شاشة تعديل جدول الطالب
  String get editScheduleTitle =>
      locale.languageCode == 'he' ? 'עריכת לוח בחינות' : 'تعديل جدول الطالب';
  String get examDeleted =>
      locale.languageCode == 'he' ? 'המבחן והמפגשים שלו נמחקו' : 'تم حذف الامتحان وجلساته';
  String get examSaved =>
      locale.languageCode == 'he' ? 'הבחינות נשמרו בהצלחה' : 'تم حفظ التعديلات بنجاح';
  String get examDateLabel =>
      locale.languageCode == 'he' ? 'תאריך' : 'التاريخ';
  String get delete =>
      locale.languageCode == 'he' ? 'מחיקה' : 'حذف';
  String get edit =>
      locale.languageCode == 'he' ? 'עריכה' : 'تعديل';
  String get examSavedSuccessfully =>
      locale.languageCode == 'he' ? 'הבחינות נשמרו בהצלחה' : 'تم حفظ التعديلات بنجاح';
  String get examDeletedMessage => locale.languageCode == 'he'
      ? 'המבחן נמחק יחד עם המפגשים'
      : 'تم حذف الامتحان وجلساته';
  String get exam =>
      locale.languageCode == 'he' ? 'מבחן' : 'الامتحان';
  String get noExam =>
      locale.languageCode == 'he' ? 'ללא מבחן' : 'لا يوجد امتحان';
  String get addStudent => locale.languageCode == 'he' ? 'הוסף תלמיד' : 'إضافة طالب';
  String get deleteStudent => locale.languageCode == 'he' ? 'מחק תלמיד' : 'حذف طالب';
  String get confirm => locale.languageCode == 'he' ? 'אישור' : 'تأكيد';
  String get studentAdded => locale.languageCode == 'he' ? 'התלמיד נוסף בהצלחה' : 'تمت إضافة الطالب بنجاح';
  String get studentDeleted => locale.languageCode == 'he' ? 'התלמיד נמחק בהצלחה' : 'تم حذف الطالب بنجاح';
  String get enterStudentIdToDelete => locale.languageCode == 'he' ? 'הכנס תעודת זהות למחיקה' : 'أدخل رقم الطالب للحذف';
  String get studentNotFound => locale.languageCode == 'he'
      ? 'לא נמצא תלמיד עם מספר זהות זה'
      : 'لا يوجد طالب بهذا الرقم';






}
