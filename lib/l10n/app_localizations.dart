import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('uz'),
    Locale('en'),
  ];

  /// No description provided for @pinTitle.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni kiriting'**
  String get pinTitle;

  /// No description provided for @pinSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga kirishni tasdiqlash uchun PIN-kodni kiriting'**
  String get pinSubtitle;

  /// No description provided for @pinIncorrect.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod noto‘g‘ri'**
  String get pinIncorrect;

  /// No description provided for @pinRetry.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, qayta urinib ko‘ring'**
  String get pinRetry;

  /// No description provided for @pinBlocked.
  ///
  /// In uz, this message translates to:
  /// **'Kirish vaqtincha bloklandi'**
  String get pinBlocked;

  /// No description provided for @pinBlockedRetryIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish uchun: {time}'**
  String pinBlockedRetryIn(String time);

  /// No description provided for @biometricUnlock.
  ///
  /// In uz, this message translates to:
  /// **'Biometrika orqali kirish'**
  String get biometricUnlock;

  /// No description provided for @biometricPromptReason.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga kirishni tasdiqlang'**
  String get biometricPromptReason;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Biometrik kirish mavjud emas'**
  String get biometricNotAvailable;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In uz, this message translates to:
  /// **'Qurilmada biometrika sozlanmagan'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricLocked.
  ///
  /// In uz, this message translates to:
  /// **'Biometrik kirish vaqtincha bloklandi'**
  String get biometricLocked;

  /// No description provided for @biometricTryPin.
  ///
  /// In uz, this message translates to:
  /// **'PIN orqali davom eting'**
  String get biometricTryPin;

  /// No description provided for @sessionExpiredLoginAgain.
  ///
  /// In uz, this message translates to:
  /// **'Sessiya tugagan. Qayta login qiling'**
  String get sessionExpiredLoginAgain;

  /// No description provided for @roleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz dasturni bir nechta rol bilan foydalanishingiz mumkin'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Quyidagilardan birini tanlang.'**
  String get roleSubtitle;

  /// No description provided for @roleAdministrator.
  ///
  /// In uz, this message translates to:
  /// **'Administrator'**
  String get roleAdministrator;

  /// No description provided for @roleManager.
  ///
  /// In uz, this message translates to:
  /// **'Menejer'**
  String get roleManager;

  /// No description provided for @roleAccountant.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchi'**
  String get roleAccountant;

  /// No description provided for @roleSupervisor.
  ///
  /// In uz, this message translates to:
  /// **'Nazoratchi'**
  String get roleSupervisor;

  /// No description provided for @roleEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get roleEmployee;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bildirishnomalar yo‘q'**
  String get notificationsEmpty;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o‘qilgan deb belgilash'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get notificationClose;

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada'**
  String get comingSoon;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @commonOpenFile.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochish'**
  String get commonOpenFile;

  /// No description provided for @commonDownloadFile.
  ///
  /// In uz, this message translates to:
  /// **'Faylni yuklab olish'**
  String get commonDownloadFile;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get navHome;

  /// No description provided for @navUsers.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilar'**
  String get navUsers;

  /// No description provided for @navTasks.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get navTasks;

  /// No description provided for @navFinance.
  ///
  /// In uz, this message translates to:
  /// **'Moliya'**
  String get navFinance;

  /// No description provided for @navReports.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotlar'**
  String get navReports;

  /// No description provided for @reportEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim bo\'yicha'**
  String get reportEmployee;

  /// No description provided for @reportProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha bo\'yicha'**
  String get reportProject;

  /// No description provided for @reportSpendingRequests.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovlari bo\'yicha'**
  String get reportSpendingRequests;

  /// No description provided for @reportWages.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi bo\'yicha'**
  String get reportWages;

  /// No description provided for @reportTasks.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar bo\'yicha'**
  String get reportTasks;

  /// No description provided for @expenseReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha xarajat so\'rovlari yo\'q'**
  String get expenseReportsEmpty;

  /// No description provided for @expenseReportUncategorized.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi'**
  String get expenseReportUncategorized;

  /// No description provided for @expenseReportAmount.
  ///
  /// In uz, this message translates to:
  /// **'Miqdori (UZS)'**
  String get expenseReportAmount;

  /// No description provided for @expenseReportUser.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get expenseReportUser;

  /// No description provided for @expenseReportAccountant.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchi'**
  String get expenseReportAccountant;

  /// No description provided for @expenseReportProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha'**
  String get expenseReportProject;

  /// No description provided for @expenseReportCategory.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat toifasi'**
  String get expenseReportCategory;

  /// No description provided for @expenseReportType.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi'**
  String get expenseReportType;

  /// No description provided for @expenseReportPaymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov turi'**
  String get expenseReportPaymentMethod;

  /// No description provided for @expenseReportPaymentCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd pul'**
  String get expenseReportPaymentCash;

  /// No description provided for @expenseReportPaymentCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqam orqali'**
  String get expenseReportPaymentCard;

  /// No description provided for @expenseReportCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get expenseReportCard;

  /// No description provided for @expenseReportCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Yaratilgan vaqti'**
  String get expenseReportCreatedAt;

  /// No description provided for @expenseReportPaidAt.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan vaqti'**
  String get expenseReportPaidAt;

  /// No description provided for @expenseReportConfirmedAt.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan vaqti'**
  String get expenseReportConfirmedAt;

  /// No description provided for @expenseReportCancelledAt.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan vaqti'**
  String get expenseReportCancelledAt;

  /// No description provided for @expenseReportReason.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov sababi'**
  String get expenseReportReason;

  /// No description provided for @expenseReportCancelReason.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi'**
  String get expenseReportCancelReason;

  /// No description provided for @expenseReportStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get expenseReportStatusPending;

  /// No description provided for @expenseReportStatusPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get expenseReportStatusPaid;

  /// No description provided for @expenseReportStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi'**
  String get expenseReportStatusConfirmed;

  /// No description provided for @expenseReportStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilindi'**
  String get expenseReportStatusCancelled;

  /// No description provided for @expenseReportTypeWithdrawal.
  ///
  /// In uz, this message translates to:
  /// **'Mablag\' chiqarish'**
  String get expenseReportTypeWithdrawal;

  /// No description provided for @expenseReportTypeCompany.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya xarajatlari'**
  String get expenseReportTypeCompany;

  /// No description provided for @expenseReportTypeOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa xarajatlar'**
  String get expenseReportTypeOther;

  /// No description provided for @expenseReportSelect.
  ///
  /// In uz, this message translates to:
  /// **'Tanlang'**
  String get expenseReportSelect;

  /// No description provided for @expenseReportAccountantHint.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchilar tanlang'**
  String get expenseReportAccountantHint;

  /// No description provided for @expenseReportProjectHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tanlang'**
  String get expenseReportProjectHint;

  /// No description provided for @expenseReportTitle.
  ///
  /// In uz, this message translates to:
  /// **'Titul'**
  String get expenseReportTitle;

  /// No description provided for @expenseReportTitleHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi bo\'yicha qidirish'**
  String get expenseReportTitleHint;

  /// No description provided for @taskReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha vazifalar yo\'q'**
  String get taskReportsEmpty;

  /// No description provided for @payrollReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha ish haqi hisobotlari yo\'q'**
  String get payrollReportsEmpty;

  /// No description provided for @payrollFixedSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS)'**
  String get payrollFixedSalary;

  /// No description provided for @payrollKpiBonus.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonusi (UZS)'**
  String get payrollKpiBonus;

  /// No description provided for @payrollPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori (UZS)'**
  String get payrollPenalty;

  /// No description provided for @payrollTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami miqdori (UZS)'**
  String get payrollTotal;

  /// No description provided for @payrollCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblangan vaqti'**
  String get payrollCreatedAt;

  /// No description provided for @payrollMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oy uchun'**
  String get payrollMonth;

  /// No description provided for @payrollStatusCalculated.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblangan'**
  String get payrollStatusCalculated;

  /// No description provided for @payrollStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get payrollStatusConfirmed;

  /// No description provided for @taskReportAssignees.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchilar'**
  String get taskReportAssignees;

  /// No description provided for @taskReportAssigneesHint.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchilar tanlang'**
  String get taskReportAssigneesHint;

  /// No description provided for @taskReportSprint.
  ///
  /// In uz, this message translates to:
  /// **'Sprint raqami'**
  String get taskReportSprint;

  /// No description provided for @taskReportPrice.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa narxi (UZS)'**
  String get taskReportPrice;

  /// No description provided for @taskReportPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizi (%)'**
  String get taskReportPenalty;

  /// No description provided for @taskReportReopened.
  ///
  /// In uz, this message translates to:
  /// **'Qaytishlar soni'**
  String get taskReportReopened;

  /// No description provided for @reportsEmployeeEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha xodimlar yo\'q'**
  String get reportsEmployeeEmpty;

  /// No description provided for @reportFixedSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS):'**
  String get reportFixedSalary;

  /// No description provided for @reportBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi (UZS):'**
  String get reportBalance;

  /// No description provided for @reportProjects.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get reportProjects;

  /// No description provided for @reportCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatilgan'**
  String get reportCompleted;

  /// No description provided for @reportTasksCount.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get reportTasksCount;

  /// No description provided for @reportTodo.
  ///
  /// In uz, this message translates to:
  /// **'Qilish kerak'**
  String get reportTodo;

  /// No description provided for @reportMeetings.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ilishlar'**
  String get reportMeetings;

  /// No description provided for @reportExpenseRequests.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi (UZS):'**
  String get reportExpenseRequests;

  /// No description provided for @reportPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get reportPaid;

  /// No description provided for @reportPayroll.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi (UZS):'**
  String get reportPayroll;

  /// No description provided for @reportKpiBonus.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonisi'**
  String get reportKpiBonus;

  /// No description provided for @reportFilterDateRange.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get reportFilterDateRange;

  /// No description provided for @reportFilterPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi'**
  String get reportFilterPosition;

  /// No description provided for @reportFilterPositionHint.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim tanlang'**
  String get reportFilterPositionHint;

  /// No description provided for @reportFilterRegion.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat'**
  String get reportFilterRegion;

  /// No description provided for @reportFilterRegionHint.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat tanlang'**
  String get reportFilterRegionHint;

  /// No description provided for @reportFilterEmployees.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get reportFilterEmployees;

  /// No description provided for @reportFilterEmployeesHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar tanlang'**
  String get reportFilterEmployeesHint;

  /// No description provided for @reportFilterSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS)'**
  String get reportFilterSalary;

  /// No description provided for @reportFilterBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi (UZS)'**
  String get reportFilterBalance;

  /// No description provided for @reportFilterExpense.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi (UZS)'**
  String get reportFilterExpense;

  /// No description provided for @reportFilterPayroll.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi (UZS)'**
  String get reportFilterPayroll;

  /// No description provided for @reportFilterFrom.
  ///
  /// In uz, this message translates to:
  /// **'dan'**
  String get reportFilterFrom;

  /// No description provided for @reportFilterTo.
  ///
  /// In uz, this message translates to:
  /// **'gacha'**
  String get reportFilterTo;

  /// No description provided for @reportFilterStatusAll.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get reportFilterStatusAll;

  /// No description provided for @reportFilterGenerate.
  ///
  /// In uz, this message translates to:
  /// **'Shakllantirish'**
  String get reportFilterGenerate;

  /// No description provided for @reportExpenseStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get reportExpenseStatusPending;

  /// No description provided for @reportExpenseStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get reportExpenseStatusConfirmed;

  /// No description provided for @reportExpenseStatusPaidUnconfirmed.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan (tasdiqlanmagan)'**
  String get reportExpenseStatusPaidUnconfirmed;

  /// No description provided for @reportPayrollTypePenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori'**
  String get reportPayrollTypePenalty;

  /// No description provided for @reportsProjectEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha loyihalar yo\'q'**
  String get reportsProjectEmpty;

  /// No description provided for @reportAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallif:'**
  String get reportAuthor;

  /// No description provided for @reportManager.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi:'**
  String get reportManager;

  /// No description provided for @reportEmployeesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar:'**
  String get reportEmployeesLabel;

  /// No description provided for @reportTestersLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar:'**
  String get reportTestersLabel;

  /// No description provided for @reportManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi bonusi (UZS):'**
  String get reportManagerBonus;

  /// No description provided for @reportStatusLabel.
  ///
  /// In uz, this message translates to:
  /// **'Holati:'**
  String get reportStatusLabel;

  /// No description provided for @reportFilterManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi bonusi'**
  String get reportFilterManagerBonus;

  /// No description provided for @reportFilterAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallifi'**
  String get reportFilterAuthor;

  /// No description provided for @reportFilterAuthorHint.
  ///
  /// In uz, this message translates to:
  /// **'Muallifi tanlang'**
  String get reportFilterAuthorHint;

  /// No description provided for @reportFilterManager.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi'**
  String get reportFilterManager;

  /// No description provided for @reportFilterManagerHint.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi tanlang'**
  String get reportFilterManagerHint;

  /// No description provided for @reportFilterTesters.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar'**
  String get reportFilterTesters;

  /// No description provided for @reportFilterTestersHint.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar tanlang'**
  String get reportFilterTestersHint;

  /// No description provided for @statPeriodSelect.
  ///
  /// In uz, this message translates to:
  /// **'Davrni tanlang'**
  String get statPeriodSelect;

  /// No description provided for @statPeriod1Month.
  ///
  /// In uz, this message translates to:
  /// **'1 oy'**
  String get statPeriod1Month;

  /// No description provided for @statPeriod3Months.
  ///
  /// In uz, this message translates to:
  /// **'3 oy'**
  String get statPeriod3Months;

  /// No description provided for @statPeriod6Months.
  ///
  /// In uz, this message translates to:
  /// **'6 oy'**
  String get statPeriod6Months;

  /// No description provided for @statPeriod1Year.
  ///
  /// In uz, this message translates to:
  /// **'1 yil'**
  String get statPeriod1Year;

  /// No description provided for @statTasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get statTasksTitle;

  /// No description provided for @statTaskTodo.
  ///
  /// In uz, this message translates to:
  /// **'Qilish kerak'**
  String get statTaskTodo;

  /// No description provided for @statTaskInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statTaskInProgress;

  /// No description provided for @statTaskDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get statTaskDone;

  /// No description provided for @statTaskProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushirilgan'**
  String get statTaskProduction;

  /// No description provided for @statTaskChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilgan'**
  String get statTaskChecked;

  /// No description provided for @statTaskRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get statTaskRejected;

  /// No description provided for @statTaskOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get statTaskOverdue;

  /// No description provided for @statProjectsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get statProjectsTitle;

  /// No description provided for @statProjectCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatilgan'**
  String get statProjectCompleted;

  /// No description provided for @statProjectActive.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statProjectActive;

  /// No description provided for @statProjectCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor'**
  String get statProjectCancelled;

  /// No description provided for @statProjectOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get statProjectOverdue;

  /// No description provided for @statProjectPlanning.
  ///
  /// In uz, this message translates to:
  /// **'Rejalashtirilgan'**
  String get statProjectPlanning;

  /// No description provided for @statMeetingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishlar dinamikasi'**
  String get statMeetingsTitle;

  /// No description provided for @statMeetingAttended.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashdi'**
  String get statMeetingAttended;

  /// No description provided for @statMeetingExcused.
  ///
  /// In uz, this message translates to:
  /// **'Sababli'**
  String get statMeetingExcused;

  /// No description provided for @statMeetingUnexcused.
  ///
  /// In uz, this message translates to:
  /// **'Sababsiz'**
  String get statMeetingUnexcused;

  /// No description provided for @statEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumot yo‘q'**
  String get statEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'{role} ma’lumotlari'**
  String profileTitle(String role);

  /// No description provided for @profileRoleManage.
  ///
  /// In uz, this message translates to:
  /// **'Rol boshqarish'**
  String get profileRoleManage;

  /// No description provided for @profileSecurity.
  ///
  /// In uz, this message translates to:
  /// **'Xafsizlik'**
  String get profileSecurity;

  /// No description provided for @profileTheme.
  ///
  /// In uz, this message translates to:
  /// **'Dizayn mavzusi'**
  String get profileTheme;

  /// No description provided for @profileAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get profileAbout;

  /// No description provided for @profileVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String profileVersion(String version);

  /// No description provided for @roleSwitchedTitle.
  ///
  /// In uz, this message translates to:
  /// **'{role} roliga o‘tildi.'**
  String roleSwitchedTitle(String role);

  /// No description provided for @profilePersonalInfo.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy kabinet'**
  String get profilePersonalInfo;

  /// No description provided for @profileLinkLabel.
  ///
  /// In uz, this message translates to:
  /// **'{index}.Havola'**
  String profileLinkLabel(int index);

  /// No description provided for @profileSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get profileSave;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar yangilandi'**
  String get profileUpdateSuccess;

  /// No description provided for @profilePhoneInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqamini +998XXXXXXXXX formatida kiriting'**
  String get profilePhoneInvalid;

  /// No description provided for @profileDistrictRequired.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat tanlangandan so‘ng tumanni ham tanlang.'**
  String get profileDistrictRequired;

  /// No description provided for @roleSwitchedSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz endi {role} sifatida ishlayapsiz.'**
  String roleSwitchedSubtitle(String role);

  /// No description provided for @tasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get tasksTitle;

  /// No description provided for @dailyPlansTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kundalik rejalar'**
  String get dailyPlansTitle;

  /// No description provided for @dailyPlansAdd.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shish'**
  String get dailyPlansAdd;

  /// No description provided for @dailyPlansSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘zingiz uchun vazifa yarating.'**
  String get dailyPlansSubtitle;

  /// No description provided for @dailyPlansEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha kundalik rejalar yo‘q'**
  String get dailyPlansEmpty;

  /// No description provided for @dailyPlansNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Reja nomini kiriting'**
  String get dailyPlansNameHint;

  /// No description provided for @dailyPlansItemHint.
  ///
  /// In uz, this message translates to:
  /// **'Kichik reja qo‘shish...'**
  String get dailyPlansItemHint;

  /// No description provided for @dailyPlansEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get dailyPlansEdit;

  /// No description provided for @dailyPlansDelete.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get dailyPlansDelete;

  /// No description provided for @dailyPlansDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Rejani o‘chirish'**
  String get dailyPlansDeleteTitle;

  /// No description provided for @dailyPlansDeleteMessage.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni ortga qaytarib bo‘lmaydi.'**
  String get dailyPlansDeleteMessage;

  /// No description provided for @dailyPlansCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get dailyPlansCancel;

  /// No description provided for @dailyPlansSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get dailyPlansSave;

  /// No description provided for @dailyPlansSaved.
  ///
  /// In uz, this message translates to:
  /// **'Reja saqlandi'**
  String get dailyPlansSaved;

  /// No description provided for @dailyPlansDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Reja o‘chirildi'**
  String get dailyPlansDeleted;

  /// No description provided for @dailyPlansDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get dailyPlansDone;

  /// No description provided for @dailyPlansUndone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilmadi'**
  String get dailyPlansUndone;

  /// No description provided for @dailyPlansMyTasks.
  ///
  /// In uz, this message translates to:
  /// **'Mening vazifalarim'**
  String get dailyPlansMyTasks;

  /// No description provided for @dailyPlansTaskName.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa nomi'**
  String get dailyPlansTaskName;

  /// No description provided for @dailyPlansDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get dailyPlansDeadline;

  /// No description provided for @dailyPlansToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get dailyPlansToday;

  /// No description provided for @dailyPlansTomorrow.
  ///
  /// In uz, this message translates to:
  /// **'Ertaga'**
  String get dailyPlansTomorrow;

  /// No description provided for @dailyPlansEditTask.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani tahrirlash'**
  String get dailyPlansEditTask;

  /// No description provided for @taskAdd.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shish'**
  String get taskAdd;

  /// No description provided for @tasksEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha vazifalar yo‘q'**
  String get tasksEmpty;

  /// No description provided for @taskPriorityLow.
  ///
  /// In uz, this message translates to:
  /// **'Past'**
  String get taskPriorityLow;

  /// No description provided for @taskPriorityMedium.
  ///
  /// In uz, this message translates to:
  /// **'O‘rta'**
  String get taskPriorityMedium;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori'**
  String get taskPriorityHigh;

  /// No description provided for @taskPriorityCritical.
  ///
  /// In uz, this message translates to:
  /// **'Kritik'**
  String get taskPriorityCritical;

  /// No description provided for @taskCreateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shish'**
  String get taskCreateTitle;

  /// No description provided for @taskCreateFieldProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha'**
  String get taskCreateFieldProject;

  /// No description provided for @taskCreateProjectHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tanlang'**
  String get taskCreateProjectHint;

  /// No description provided for @taskCreateFieldName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get taskCreateFieldName;

  /// No description provided for @taskCreateNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi kiriting'**
  String get taskCreateNameHint;

  /// No description provided for @taskCreateFieldDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsifi'**
  String get taskCreateFieldDescription;

  /// No description provided for @taskCreateDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Tavsifini yozing'**
  String get taskCreateDescriptionHint;

  /// No description provided for @taskCreateFieldPriority.
  ///
  /// In uz, this message translates to:
  /// **'Darajasi'**
  String get taskCreateFieldPriority;

  /// No description provided for @taskCreatePriorityHint.
  ///
  /// In uz, this message translates to:
  /// **'Darajasi tanlang'**
  String get taskCreatePriorityHint;

  /// No description provided for @taskCreateFieldType.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get taskCreateFieldType;

  /// No description provided for @taskCreateTypeHint.
  ///
  /// In uz, this message translates to:
  /// **'Turini tanlang'**
  String get taskCreateTypeHint;

  /// No description provided for @taskTypeBug.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik (Bug)'**
  String get taskTypeBug;

  /// No description provided for @taskTypeFeature.
  ///
  /// In uz, this message translates to:
  /// **'Yangi funksiya'**
  String get taskTypeFeature;

  /// No description provided for @taskTypeAddition.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha'**
  String get taskTypeAddition;

  /// No description provided for @taskTypeResearch.
  ///
  /// In uz, this message translates to:
  /// **'Tadqiqot/O‘rganish'**
  String get taskTypeResearch;

  /// No description provided for @taskCreateFieldAssigner.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchi'**
  String get taskCreateFieldAssigner;

  /// No description provided for @taskCreateSelectProjectFirst.
  ///
  /// In uz, this message translates to:
  /// **'Avval loyihani tanlang'**
  String get taskCreateSelectProjectFirst;

  /// No description provided for @taskCreateFieldPositions.
  ///
  /// In uz, this message translates to:
  /// **'Kimlar uchun'**
  String get taskCreateFieldPositions;

  /// No description provided for @taskCreatePositionsHint.
  ///
  /// In uz, this message translates to:
  /// **'Tanlang'**
  String get taskCreatePositionsHint;

  /// No description provided for @taskCreateFieldSprint.
  ///
  /// In uz, this message translates to:
  /// **'Sprint'**
  String get taskCreateFieldSprint;

  /// No description provided for @taskCreateFieldPrice.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa narxi (UZS)'**
  String get taskCreateFieldPrice;

  /// No description provided for @taskCreatePriceHint.
  ///
  /// In uz, this message translates to:
  /// **'0,00'**
  String get taskCreatePriceHint;

  /// No description provided for @taskCreateFieldPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizi (%)'**
  String get taskCreateFieldPenalty;

  /// No description provided for @taskCreatePenaltyHint.
  ///
  /// In uz, this message translates to:
  /// **'Jarima'**
  String get taskCreatePenaltyHint;

  /// No description provided for @taskCreateFieldDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get taskCreateFieldDeadline;

  /// No description provided for @taskCreateFieldTime.
  ///
  /// In uz, this message translates to:
  /// **'Vaqti'**
  String get taskCreateFieldTime;

  /// No description provided for @taskCreateFieldEstimated.
  ///
  /// In uz, this message translates to:
  /// **'Taxminiy vaqt'**
  String get taskCreateFieldEstimated;

  /// No description provided for @taskCreateFieldFiles.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha fayllar'**
  String get taskCreateFieldFiles;

  /// No description provided for @taskCreateFileUpload.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuklash'**
  String get taskCreateFileUpload;

  /// No description provided for @taskCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha, nomi va muddat majburiy'**
  String get taskCreateRequiredError;

  /// No description provided for @taskDeadlineChangeRequired.
  ///
  /// In uz, this message translates to:
  /// **'Muddatni o‘zgartiring'**
  String get taskDeadlineChangeRequired;

  /// No description provided for @taskCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shildi'**
  String get taskCreateSuccess;

  /// No description provided for @taskEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani tahrirlash'**
  String get taskEditTitle;

  /// No description provided for @taskEditSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get taskEditSave;

  /// No description provided for @taskUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa yangilandi'**
  String get taskUpdateSuccess;

  /// No description provided for @taskDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get taskDetailTitle;

  /// No description provided for @taskDetailCreatedBy.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchi'**
  String get taskDetailCreatedBy;

  /// No description provided for @taskDetailRejectReason.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilish sababi'**
  String get taskDetailRejectReason;

  /// No description provided for @taskActionChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirildi'**
  String get taskActionChecked;

  /// No description provided for @taskActionRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get taskActionRejected;

  /// No description provided for @taskActionInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonga o‘tkazish'**
  String get taskActionInProgress;

  /// No description provided for @taskActionMarkDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilganga o‘tkazish'**
  String get taskActionMarkDone;

  /// No description provided for @taskActionProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushurildi'**
  String get taskActionProduction;

  /// No description provided for @taskActionEditDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddatni o‘zgartirish'**
  String get taskActionEditDeadline;

  /// No description provided for @taskRejectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani rad etish'**
  String get taskRejectTitle;

  /// No description provided for @taskRejectSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish sababini kiriting'**
  String get taskRejectSubtitle;

  /// No description provided for @taskRejectHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababini yozing...'**
  String get taskRejectHint;

  /// No description provided for @taskRejectConfirm.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get taskRejectConfirm;

  /// No description provided for @taskStatusUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Holat yangilandi'**
  String get taskStatusUpdated;

  /// No description provided for @meetingEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni tahrirlash'**
  String get meetingEditTitle;

  /// No description provided for @meetingDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish tafsilotlari'**
  String get meetingDetailTitle;

  /// No description provided for @meetingDetailParticipantsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qatnashchilari'**
  String get meetingDetailParticipantsLabel;

  /// No description provided for @meetingUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish yangilandi'**
  String get meetingUpdateSuccess;

  /// No description provided for @meetingCloseAction.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni yakunlash'**
  String get meetingCloseAction;

  /// No description provided for @meetingCloseSheetTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish ishtirokchilarini belgilang'**
  String get meetingCloseSheetTitle;

  /// No description provided for @meetingCloseSheetSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashgan xodimlarni tanlang'**
  String get meetingCloseSheetSubtitle;

  /// No description provided for @meetingCloseConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get meetingCloseConfirm;

  /// No description provided for @meetingCloseSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish yakunlandi'**
  String get meetingCloseSuccess;

  /// No description provided for @meetingExcuseListTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashmaganlar sabablari'**
  String get meetingExcuseListTitle;

  /// No description provided for @meetingExcuseNoReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab hali yozilmagan'**
  String get meetingExcuseNoReason;

  /// No description provided for @meetingExcuseAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Sabab qabul qilindi'**
  String get meetingExcuseAccepted;

  /// No description provided for @meetingExcuseReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get meetingExcuseReject;

  /// No description provided for @meetingExcuseRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get meetingExcuseRejected;

  /// No description provided for @meetingMyAttended.
  ///
  /// In uz, this message translates to:
  /// **'Siz yig‘ilishda qatnashgansiz'**
  String get meetingMyAttended;

  /// No description provided for @meetingMyNotAttended.
  ///
  /// In uz, this message translates to:
  /// **'Siz yig‘ilishda qatnashmagansiz'**
  String get meetingMyNotAttended;

  /// No description provided for @meetingSendReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborish'**
  String get meetingSendReason;

  /// No description provided for @meetingReasonSentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborilgan'**
  String get meetingReasonSentLabel;

  /// No description provided for @meetingDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni o‘chirish'**
  String get meetingDeleteTitle;

  /// No description provided for @meetingDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.'**
  String get meetingDeleteSubtitle;

  /// No description provided for @projectCreateFilesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha hujjatlari'**
  String get projectCreateFilesLabel;

  /// No description provided for @projectExistingFilesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud hujjatlar'**
  String get projectExistingFilesLabel;

  /// No description provided for @projectCreateDocsFailed.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha yaratildi, lekin ba\'zi hujjatlar qo‘shilmadi'**
  String get projectCreateDocsFailed;

  /// No description provided for @projectUpdateDocsFailed.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha saqlandi, lekin ba\'zi hujjatlar qo‘shilmadi'**
  String get projectUpdateDocsFailed;

  /// No description provided for @projectDocumentNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomini kiriting'**
  String get projectDocumentNameHint;

  /// No description provided for @projectDocumentLinkHint.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi'**
  String get projectDocumentLinkHint;

  /// No description provided for @projectDocumentAddButton.
  ///
  /// In uz, this message translates to:
  /// **'Hujjat qo‘shish'**
  String get projectDocumentAddButton;

  /// No description provided for @projectDocumentLinkCopied.
  ///
  /// In uz, this message translates to:
  /// **'Havola nusxalandi'**
  String get projectDocumentLinkCopied;

  /// No description provided for @taskMenuDetails.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get taskMenuDetails;

  /// No description provided for @taskMenuDelete.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get taskMenuDelete;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani o‘chirish'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.'**
  String get taskDeleteSubtitle;

  /// No description provided for @taskDeleteCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get taskDeleteCancel;

  /// No description provided for @taskFilterTitle.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlash'**
  String get taskFilterTitle;

  /// No description provided for @taskFilterStatus.
  ///
  /// In uz, this message translates to:
  /// **'Holati'**
  String get taskFilterStatus;

  /// No description provided for @taskFilterAllStatuses.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get taskFilterAllStatuses;

  /// No description provided for @taskFilterStatusHint.
  ///
  /// In uz, this message translates to:
  /// **'Holati tanlang'**
  String get taskFilterStatusHint;

  /// No description provided for @taskStatusTodo.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilishi kerak'**
  String get taskStatusTodo;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get taskStatusOverdue;

  /// No description provided for @taskStatusDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get taskStatusDone;

  /// No description provided for @taskStatusProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushirilgan'**
  String get taskStatusProduction;

  /// No description provided for @taskStatusChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilgan'**
  String get taskStatusChecked;

  /// No description provided for @taskStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get taskStatusRejected;

  /// No description provided for @taskFilterAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallif'**
  String get taskFilterAuthor;

  /// No description provided for @taskFilterAuthorHint.
  ///
  /// In uz, this message translates to:
  /// **'Muallif tanlang'**
  String get taskFilterAuthorHint;

  /// No description provided for @taskFilterEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get taskFilterEmployee;

  /// No description provided for @taskFilterEmployeeHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim tanlang'**
  String get taskFilterEmployeeHint;

  /// No description provided for @taskFilterDeadlineRange.
  ///
  /// In uz, this message translates to:
  /// **'Muddat oralig‘i'**
  String get taskFilterDeadlineRange;

  /// No description provided for @taskFilterDateHint.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get taskFilterDateHint;

  /// No description provided for @taskFilterReset.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get taskFilterReset;

  /// No description provided for @taskFilterApply.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get taskFilterApply;

  /// No description provided for @taskSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Izlash'**
  String get taskSearchHint;

  /// No description provided for @taskSearchClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get taskSearchClose;

  /// No description provided for @taskFilterSelectAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shish'**
  String get taskFilterSelectAdd;

  /// No description provided for @taskFilterSelectedCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta tanlangan'**
  String taskFilterSelectedCount(int count);

  /// No description provided for @projectsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get projectsTitle;

  /// No description provided for @projectAdd.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha qo‘shish'**
  String get projectAdd;

  /// No description provided for @projectsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha loyihalar yo‘q'**
  String get projectsEmpty;

  /// No description provided for @projectSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha izlash'**
  String get projectSearchHint;

  /// No description provided for @projectFilterManager.
  ///
  /// In uz, this message translates to:
  /// **'Menejer'**
  String get projectFilterManager;

  /// No description provided for @projectFilterManagerHint.
  ///
  /// In uz, this message translates to:
  /// **'Menejer tanlang'**
  String get projectFilterManagerHint;

  /// No description provided for @projectFilterTitleField.
  ///
  /// In uz, this message translates to:
  /// **'Titul'**
  String get projectFilterTitleField;

  /// No description provided for @projectFilterTitleHint.
  ///
  /// In uz, this message translates to:
  /// **'Titul bo‘yicha izlash'**
  String get projectFilterTitleHint;

  /// No description provided for @projectCreateDefaultPrefix.
  ///
  /// In uz, this message translates to:
  /// **'ERAF'**
  String get projectCreateDefaultPrefix;

  /// No description provided for @projectCreateDefaultPenalty.
  ///
  /// In uz, this message translates to:
  /// **'20'**
  String get projectCreateDefaultPenalty;

  /// No description provided for @projectCreateManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Menejer bonusi'**
  String get projectCreateManagerBonus;

  /// No description provided for @projectCreateManagerBonusHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha uchun: 0,0'**
  String get projectCreateManagerBonusHint;

  /// No description provided for @projectCreatePrefixHint.
  ///
  /// In uz, this message translates to:
  /// **'Titul kiriting'**
  String get projectCreatePrefixHint;

  /// No description provided for @projectCreateEmployees.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get projectCreateEmployees;

  /// No description provided for @projectCreateEmployeesHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim tanlang'**
  String get projectCreateEmployeesHint;

  /// No description provided for @projectUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha yangilandi'**
  String get projectUpdateSuccess;

  /// No description provided for @projectDetailsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tafsilotlari'**
  String get projectDetailsTitle;

  /// No description provided for @projectEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani tahrirlash'**
  String get projectEditTitle;

  /// No description provided for @projectMenuEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get projectMenuEdit;

  /// No description provided for @projectMenuDetails.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get projectMenuDetails;

  /// No description provided for @projectMenuDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get projectMenuDelete;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani o\'chirish'**
  String get projectDeleteTitle;

  /// No description provided for @projectDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani rostdan ham o\'chirmoqchimisiz? O\'chirilgan loyihani chiqindi qutisidan tiklashingiz mumkin.'**
  String get projectDeleteSubtitle;

  /// No description provided for @projectDeleteCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get projectDeleteCancel;

  /// No description provided for @projectCreateTesters.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar'**
  String get projectCreateTesters;

  /// No description provided for @projectCreateTestersHint.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchi tanlang'**
  String get projectCreateTestersHint;

  /// No description provided for @projectCreateActive.
  ///
  /// In uz, this message translates to:
  /// **'Faolmi?'**
  String get projectCreateActive;

  /// No description provided for @projectCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Nomi, titul, menejer va muddat majburiy'**
  String get projectCreateRequiredError;

  /// No description provided for @projectCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha qo‘shildi'**
  String get projectCreateSuccess;

  /// No description provided for @projectStatusPlanning.
  ///
  /// In uz, this message translates to:
  /// **'Rejalashtirilmoqda'**
  String get projectStatusPlanning;

  /// No description provided for @projectStatusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get projectStatusActive;

  /// No description provided for @projectStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get projectStatusOverdue;

  /// No description provided for @projectStatusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan'**
  String get projectStatusCompleted;

  /// No description provided for @projectStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get projectStatusCancelled;

  /// No description provided for @meetingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishlar'**
  String get meetingsTitle;

  /// No description provided for @meetingAdd.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qo‘shish'**
  String get meetingAdd;

  /// No description provided for @meetingsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yig‘ilishlar yo‘q'**
  String get meetingsEmpty;

  /// No description provided for @meetingFilterOrganizer.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi'**
  String get meetingFilterOrganizer;

  /// No description provided for @meetingFilterOrganizerHint.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchini tanlang'**
  String get meetingFilterOrganizerHint;

  /// No description provided for @meetingFilterStartDateRange.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi oralig‘i'**
  String get meetingFilterStartDateRange;

  /// No description provided for @meetingCreateNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi yozing'**
  String get meetingCreateNameHint;

  /// No description provided for @meetingCreatePenaltyHint.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizini kiriting'**
  String get meetingCreatePenaltyHint;

  /// No description provided for @meetingCreateLink.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi'**
  String get meetingCreateLink;

  /// No description provided for @meetingCreateLinkHint.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi kiriting: URL manzil'**
  String get meetingCreateLinkHint;

  /// No description provided for @meetingCreateDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif yozing'**
  String get meetingCreateDescriptionHint;

  /// No description provided for @meetingCreateStartDate.
  ///
  /// In uz, this message translates to:
  /// **'Muddat sanasi'**
  String get meetingCreateStartDate;

  /// No description provided for @meetingCreateDuration.
  ///
  /// In uz, this message translates to:
  /// **'Davomiyligi'**
  String get meetingCreateDuration;

  /// No description provided for @meetingCreateDurationHint.
  ///
  /// In uz, this message translates to:
  /// **'Daqiqa'**
  String get meetingCreateDurationHint;

  /// No description provided for @meetingCreateParticipantsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qatnashchilarini qo‘shish'**
  String get meetingCreateParticipantsLabel;

  /// No description provided for @meetingCreateParticipantsHelp.
  ///
  /// In uz, this message translates to:
  /// **'Quyidagi tugma orqali qidiring va tanlang'**
  String get meetingCreateParticipantsHelp;

  /// No description provided for @meetingCreateParticipantsAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashchilarni qo‘shing'**
  String get meetingCreateParticipantsAdd;

  /// No description provided for @meetingCreateParticipantsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashchilarni qo‘shish'**
  String get meetingCreateParticipantsTitle;

  /// No description provided for @meetingPreviewDetailsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish ma’lumotlari'**
  String get meetingPreviewDetailsTitle;

  /// No description provided for @meetingPreviewApprovalTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash talabi'**
  String get meetingPreviewApprovalTitle;

  /// No description provided for @meetingPreviewApprovalDescription.
  ///
  /// In uz, this message translates to:
  /// **'Yoqilsa, har bir ishtirokchini yaratuvchi, loyiha menejeri yoki admin tasdiqlaydi.'**
  String get meetingPreviewApprovalDescription;

  /// No description provided for @meetingPreviewActive.
  ///
  /// In uz, this message translates to:
  /// **'Davom etmoqda'**
  String get meetingPreviewActive;

  /// No description provided for @meetingPreviewJoin.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishga kirish'**
  String get meetingPreviewJoin;

  /// No description provided for @meetingPreviewSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get meetingPreviewSave;

  /// No description provided for @meetingPreviewProject.
  ///
  /// In uz, this message translates to:
  /// **'Marketing Platform'**
  String get meetingPreviewProject;

  /// No description provided for @meetingPreviewProjectSecond.
  ///
  /// In uz, this message translates to:
  /// **'Raqamli Nazorat'**
  String get meetingPreviewProjectSecond;

  /// No description provided for @meetingPreviewName.
  ///
  /// In uz, this message translates to:
  /// **'Test qilish'**
  String get meetingPreviewName;

  /// No description provided for @meetingPreviewPenalty.
  ///
  /// In uz, this message translates to:
  /// **'20'**
  String get meetingPreviewPenalty;

  /// No description provided for @meetingPreviewDescription.
  ///
  /// In uz, this message translates to:
  /// **'CRM tizimida yangi “Hisobotlar” bo‘limini qo‘shish. Admin barcha ma’lumotlarni ko‘ra olishi kerak.'**
  String get meetingPreviewDescription;

  /// No description provided for @meetingPreviewParticipantOne.
  ///
  /// In uz, this message translates to:
  /// **'Ali Valiyev'**
  String get meetingPreviewParticipantOne;

  /// No description provided for @meetingPreviewParticipantTwo.
  ///
  /// In uz, this message translates to:
  /// **'Madina Karimova'**
  String get meetingPreviewParticipantTwo;

  /// No description provided for @meetingCreateCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatildimi?'**
  String get meetingCreateCompleted;

  /// No description provided for @meetingCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha, nomi, havolasi, tavsifi, sana va davomiyligi majburiy'**
  String get meetingCreateRequiredError;

  /// No description provided for @meetingCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qo‘shildi'**
  String get meetingCreateSuccess;

  /// No description provided for @meetingReasonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishga qatnashmadingiz'**
  String get meetingReasonTitle;

  /// No description provided for @meetingReasonPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, qatnashmaganlik sababini kiriting'**
  String get meetingReasonPrompt;

  /// No description provided for @meetingReasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababni yozing...'**
  String get meetingReasonHint;

  /// No description provided for @meetingReasonSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get meetingReasonSubmit;

  /// No description provided for @meetingReasonSentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborildi.'**
  String get meetingReasonSentTitle;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqmoqchimisiz?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqasiz va qayta kirish uchun tizimga yana login qilishingiz kerak bo‘ladi'**
  String get profileLogoutSubtitle;

  /// No description provided for @profileLogoutBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get profileLogoutBack;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get profileLogoutConfirm;

  /// No description provided for @profileThemeSheetTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dizayn mavzusi'**
  String get profileThemeSheetTitle;

  /// No description provided for @profileThemeSheetSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova qanday ko‘rinishini tanlang.'**
  String get profileThemeSheetSubtitle;

  /// No description provided for @profileThemeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug‘lik rejimi'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong‘i rejim'**
  String get profileThemeDark;

  /// No description provided for @securityChangePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol o‘zgartirish'**
  String get securityChangePassword;

  /// No description provided for @securityAutoLock.
  ///
  /// In uz, this message translates to:
  /// **'Avtomatik qulflash'**
  String get securityAutoLock;

  /// No description provided for @securityAutoLockSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Faoliyatsizlikdan so‘ng PIN kodni qayta kiritish talab qilinadi.'**
  String get securityAutoLockSubtitle;

  /// No description provided for @securityAutoLockImmediately.
  ///
  /// In uz, this message translates to:
  /// **'Darhol'**
  String get securityAutoLockImmediately;

  /// No description provided for @securityAutoLock1Minute.
  ///
  /// In uz, this message translates to:
  /// **'1 daqiqa'**
  String get securityAutoLock1Minute;

  /// No description provided for @securityAutoLock5Minutes.
  ///
  /// In uz, this message translates to:
  /// **'5 daqiqa'**
  String get securityAutoLock5Minutes;

  /// No description provided for @securityAutoLock15Minutes.
  ///
  /// In uz, this message translates to:
  /// **'15 daqiqa'**
  String get securityAutoLock15Minutes;

  /// No description provided for @securityAutoLock30Minutes.
  ///
  /// In uz, this message translates to:
  /// **'30 daqiqa'**
  String get securityAutoLock30Minutes;

  /// No description provided for @securityAutoLock1Hour.
  ///
  /// In uz, this message translates to:
  /// **'1 soat'**
  String get securityAutoLock1Hour;

  /// No description provided for @changePasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o‘zgartirish'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik uchun joriy parolingizni kiriting va yangi parol o‘rnating.'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordOldLabel.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol'**
  String get changePasswordOldLabel;

  /// No description provided for @changePasswordOldHint.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parolni kiriting'**
  String get changePasswordOldHint;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni kiriting'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlash'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni qayta kiriting'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordErrorOldWrong.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol noto‘g‘ri'**
  String get changePasswordErrorOldWrong;

  /// No description provided for @changePasswordErrorMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get changePasswordErrorMismatch;

  /// No description provided for @changePasswordCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get changePasswordCancel;

  /// No description provided for @changePasswordSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get changePasswordSave;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Parol muvaffaqiyatli o‘zgartirildi.'**
  String get changePasswordSuccess;

  /// No description provided for @commonError.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.'**
  String get commonError;

  /// No description provided for @networkError.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo‘q. Ulanishni tekshiring.'**
  String get networkError;

  /// No description provided for @usersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha foydalanuvchilar yo\'q'**
  String get usersEmpty;

  /// No description provided for @userFullNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ism sharifi:'**
  String get userFullNameLabel;

  /// No description provided for @userPositionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi:'**
  String get userPositionLabel;

  /// No description provided for @userRoleLabel.
  ///
  /// In uz, this message translates to:
  /// **'Rol:'**
  String get userRoleLabel;

  /// No description provided for @userSalaryLabel.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi:'**
  String get userSalaryLabel;

  /// No description provided for @userBalanceLabel.
  ///
  /// In uz, this message translates to:
  /// **'Balansi:'**
  String get userBalanceLabel;

  /// No description provided for @usersFilterAllPositions.
  ///
  /// In uz, this message translates to:
  /// **'Barcha lavozimlar'**
  String get usersFilterAllPositions;

  /// No description provided for @usersFilterAllRoles.
  ///
  /// In uz, this message translates to:
  /// **'Barcha rollar'**
  String get usersFilterAllRoles;

  /// No description provided for @usersSortNameAsc.
  ///
  /// In uz, this message translates to:
  /// **'A dan Z gacha'**
  String get usersSortNameAsc;

  /// No description provided for @usersSortNameDesc.
  ///
  /// In uz, this message translates to:
  /// **'Z dan A gacha'**
  String get usersSortNameDesc;

  /// No description provided for @usersSortNewest.
  ///
  /// In uz, this message translates to:
  /// **'Yangi → Eski'**
  String get usersSortNewest;

  /// No description provided for @usersSortOldest.
  ///
  /// In uz, this message translates to:
  /// **'Eski → Yangi'**
  String get usersSortOldest;

  /// No description provided for @userCreateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xodim qo‘shish'**
  String get userCreateTitle;

  /// No description provided for @userCreateNameHint.
  ///
  /// In uz, this message translates to:
  /// **'F.I.O kiriting'**
  String get userCreateNameHint;

  /// No description provided for @userCreatePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get userCreatePassword;

  /// No description provided for @userCreateConfirmPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlang'**
  String get userCreateConfirmPassword;

  /// No description provided for @userCreatePasswordMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar bir xil emas'**
  String get userCreatePasswordMismatch;

  /// No description provided for @userCreateSalaryInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Maosh formatini tekshiring'**
  String get userCreateSalaryInvalid;

  /// No description provided for @userCreateDistrictHint.
  ///
  /// In uz, this message translates to:
  /// **'Tuman tanlang'**
  String get userCreateDistrictHint;

  /// No description provided for @userCreateAvatarUpload.
  ///
  /// In uz, this message translates to:
  /// **'Avatar yuklash'**
  String get userCreateAvatarUpload;

  /// No description provided for @userCreateImageUpload.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklash'**
  String get userCreateImageUpload;

  /// No description provided for @userCreateLinkHint.
  ///
  /// In uz, this message translates to:
  /// **'Havola kiriting'**
  String get userCreateLinkHint;

  /// No description provided for @userCreateSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shish'**
  String get userCreateSubmit;

  /// No description provided for @userCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi qo‘shildi'**
  String get userCreateSuccess;

  /// No description provided for @userCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Majburiy maydonlarni to‘ldiring'**
  String get userCreateRequiredError;

  /// No description provided for @userDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchining ma’lumotlari'**
  String get userDetailTitle;

  /// No description provided for @userDetailFullName.
  ///
  /// In uz, this message translates to:
  /// **'Ism Sharifi'**
  String get userDetailFullName;

  /// No description provided for @userDetailCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Yaratilgan vaqt'**
  String get userDetailCreatedAt;

  /// No description provided for @userDetailPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get userDetailPhone;

  /// No description provided for @userDetailCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get userDetailCard;

  /// No description provided for @userDetailSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maosh'**
  String get userDetailSalary;

  /// No description provided for @userDetailBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi'**
  String get userDetailBalance;

  /// No description provided for @userDetailDistrict.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get userDetailDistrict;

  /// No description provided for @userDetailPassport.
  ///
  /// In uz, this message translates to:
  /// **'Passport ma’lumotlari'**
  String get userDetailPassport;

  /// No description provided for @userDetailPassportImage.
  ///
  /// In uz, this message translates to:
  /// **'Passport rasmi'**
  String get userDetailPassportImage;

  /// No description provided for @userDetailPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi'**
  String get userDetailPosition;

  /// No description provided for @userDetailRole.
  ///
  /// In uz, this message translates to:
  /// **'Roli'**
  String get userDetailRole;

  /// No description provided for @financeExpenseRequests.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovlari'**
  String get financeExpenseRequests;

  /// No description provided for @financeWages.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi'**
  String get financeWages;

  /// No description provided for @financeHistory.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get financeHistory;

  /// No description provided for @ledgerEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yozuvlar yo\'q'**
  String get ledgerEmpty;

  /// No description provided for @ledgerTypeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Turi:'**
  String get ledgerTypeLabel;

  /// No description provided for @ledgerAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor:'**
  String get ledgerAmountLabel;

  /// No description provided for @ledgerDateLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sana:'**
  String get ledgerDateLabel;

  /// No description provided for @ledgerTypeExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get ledgerTypeExpense;

  /// No description provided for @ledgerTypeIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get ledgerTypeIncome;

  /// No description provided for @ledgerDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarix ma’lumotlari'**
  String get ledgerDetailTitle;

  /// No description provided for @ledgerDetailExpenseType.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi'**
  String get ledgerDetailExpenseType;

  /// No description provided for @ledgerDetailAmount.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor'**
  String get ledgerDetailAmount;

  /// No description provided for @ledgerDetailConfirmedAt.
  ///
  /// In uz, this message translates to:
  /// **'Tastiqlangan vaqt'**
  String get ledgerDetailConfirmedAt;

  /// No description provided for @ledgerFilterExpenseType.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi'**
  String get ledgerFilterExpenseType;

  /// No description provided for @ledgerFilterExpenseTypeHint.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turini tanlang'**
  String get ledgerFilterExpenseTypeHint;

  /// No description provided for @ledgerFilterDateRange.
  ///
  /// In uz, this message translates to:
  /// **'Sana oralig\'i'**
  String get ledgerFilterDateRange;

  /// No description provided for @ledgerFilterAmount.
  ///
  /// In uz, this message translates to:
  /// **'Miqdor'**
  String get ledgerFilterAmount;

  /// No description provided for @payrollEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yozuvlar yo\'q'**
  String get payrollEmpty;

  /// No description provided for @payrollMonthLabel.
  ///
  /// In uz, this message translates to:
  /// **'Oy:'**
  String get payrollMonthLabel;

  /// No description provided for @payrollKpiLabel.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonus:'**
  String get payrollKpiLabel;

  /// No description provided for @payrollTotalLabel.
  ///
  /// In uz, this message translates to:
  /// **'Jami miqdori:'**
  String get payrollTotalLabel;

  /// No description provided for @payrollDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi ma’lumotlari'**
  String get payrollDetailTitle;

  /// No description provided for @payrollMonthField.
  ///
  /// In uz, this message translates to:
  /// **'Oy'**
  String get payrollMonthField;

  /// No description provided for @payrollSalaryField.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maosh (UZS)'**
  String get payrollSalaryField;

  /// No description provided for @payrollKpiField.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonus'**
  String get payrollKpiField;

  /// No description provided for @payrollPenaltyField.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori'**
  String get payrollPenaltyField;

  /// No description provided for @payrollTotalField.
  ///
  /// In uz, this message translates to:
  /// **'Jami miqdori'**
  String get payrollTotalField;

  /// No description provided for @payrollConfirmButton.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get payrollConfirmButton;

  /// No description provided for @payrollConfirmSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi tasdiqlandi'**
  String get payrollConfirmSuccess;

  /// No description provided for @payrollConfirmDialogTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqini tasdiqlaysizmi?'**
  String get payrollConfirmDialogTitle;

  /// No description provided for @payrollConfirmDialogSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangandan so\'ng bu amalni bekor qilib bo\'lmaydi'**
  String get payrollConfirmDialogSubtitle;

  /// No description provided for @payrollFilterMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oy'**
  String get payrollFilterMonth;

  /// No description provided for @payrollFilterMonthHint.
  ///
  /// In uz, this message translates to:
  /// **'Oy tanlang'**
  String get payrollFilterMonthHint;

  /// No description provided for @payrollFilterCreatedRange.
  ///
  /// In uz, this message translates to:
  /// **'Yaratilgan vaqti oralig\'i'**
  String get payrollFilterCreatedRange;

  /// No description provided for @payrollFilterTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami miqdori (UZS)'**
  String get payrollFilterTotal;

  /// No description provided for @payrollFilterPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori'**
  String get payrollFilterPenalty;

  /// No description provided for @payrollFilterApply.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get payrollFilterApply;

  /// No description provided for @expenseRequestProjectLabel.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha:'**
  String get expenseRequestProjectLabel;

  /// No description provided for @expenseRequestTypeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi:'**
  String get expenseRequestTypeLabel;

  /// No description provided for @expenseRequestAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Summasi:'**
  String get expenseRequestAmountLabel;

  /// No description provided for @expenseRequestFilterCategory.
  ///
  /// In uz, this message translates to:
  /// **'Toifa'**
  String get expenseRequestFilterCategory;

  /// No description provided for @expenseRequestFilterCategoryHint.
  ///
  /// In uz, this message translates to:
  /// **'Toifani tanlang'**
  String get expenseRequestFilterCategoryHint;

  /// No description provided for @expenseRequestFilterAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get expenseRequestFilterAmount;

  /// No description provided for @expenseRequestFilterPaidRange.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan vaqti oralig\'i'**
  String get expenseRequestFilterPaidRange;

  /// No description provided for @expenseRequestFilterConfirmedRange.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan vaqti oralig\'i'**
  String get expenseRequestFilterConfirmedRange;

  /// No description provided for @expenseRequestDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov ma\'lumotlari'**
  String get expenseRequestDetailTitle;

  /// No description provided for @expenseRequestAmountField.
  ///
  /// In uz, this message translates to:
  /// **'Summa (UZS)'**
  String get expenseRequestAmountField;

  /// No description provided for @expenseRequestReasonField.
  ///
  /// In uz, this message translates to:
  /// **'Sababi'**
  String get expenseRequestReasonField;

  /// No description provided for @expenseRequestPayButton.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qildim'**
  String get expenseRequestPayButton;

  /// No description provided for @expenseRequestPayDialogTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov amalga oshirilganini tasdiqlaysizmi?'**
  String get expenseRequestPayDialogTitle;

  /// No description provided for @expenseRequestPayDialogSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu orqali to\'lov amalga oshirilgani tizimda qayd etiladi.'**
  String get expenseRequestPayDialogSubtitle;

  /// No description provided for @expenseRequestCancelReasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, sababni yozing. Bu majburiy'**
  String get expenseRequestCancelReasonHint;

  /// No description provided for @expenseRequestPaySuccess.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov qayd etildi.'**
  String get expenseRequestPaySuccess;

  /// No description provided for @expenseRequestPaySuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'Mablag\' berilgani tizimda belgilandi.'**
  String get expenseRequestPaySuccessMessage;

  /// No description provided for @expenseRequestCancelSuccess.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov rad etildi.'**
  String get expenseRequestCancelSuccess;

  /// No description provided for @expenseRequestCancelSuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov bo\'yicha rad etish sababi saqlandi.'**
  String get expenseRequestCancelSuccessMessage;

  /// No description provided for @expenseRequestReceiptDialogTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov chekini yuklang.'**
  String get expenseRequestReceiptDialogTitle;

  /// No description provided for @expenseRequestReceiptDialogSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov tasdiqlanishi uchun chek yoki kvitansiyani yuklang.'**
  String get expenseRequestReceiptDialogSubtitle;

  /// No description provided for @expenseRequestReceiptInfo.
  ///
  /// In uz, this message translates to:
  /// **'Chek faylini hozir yuklamasangiz ham bo\'ladi. Uni keyinroq qo\'shishingiz mumkin.'**
  String get expenseRequestReceiptInfo;

  /// No description provided for @expenseRequestReceiptAddTile.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov chekini yuklash'**
  String get expenseRequestReceiptAddTile;

  /// No description provided for @expenseRequestReceiptSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get expenseRequestReceiptSkip;

  /// No description provided for @expenseRequestReceiptSend.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get expenseRequestReceiptSend;

  /// No description provided for @expenseRequestReceiptsTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov cheklari'**
  String get expenseRequestReceiptsTitle;

  /// No description provided for @expenseRequestReceiptViewerTitle.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov cheki'**
  String get expenseRequestReceiptViewerTitle;

  /// No description provided for @expenseRequestStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get expenseRequestStatusRejected;

  /// No description provided for @expenseRequestConfirmButton.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get expenseRequestConfirmButton;

  /// No description provided for @expenseRequestConfirmSuccess.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov tasdiqlandi.'**
  String get expenseRequestConfirmSuccess;

  /// No description provided for @expenseRequestConfirmSuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash tizimda qayd etildi.'**
  String get expenseRequestConfirmSuccessMessage;

  /// No description provided for @expenseRequestCardCopied.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami nusxalandi'**
  String get expenseRequestCardCopied;

  /// No description provided for @expenseRequestCreateTitle.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov yuborish'**
  String get expenseRequestCreateTitle;

  /// No description provided for @expenseRequestCreateSubmit.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov yuborish'**
  String get expenseRequestCreateSubmit;

  /// No description provided for @expenseRequestCreateProjectLabel.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha uchun'**
  String get expenseRequestCreateProjectLabel;

  /// No description provided for @expenseRequestCreateAmountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Miqdori'**
  String get expenseRequestCreateAmountLabel;

  /// No description provided for @expenseRequestCreateAmountHint.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting: 0,00'**
  String get expenseRequestCreateAmountHint;

  /// No description provided for @expenseRequestCreateReasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababini yozing'**
  String get expenseRequestCreateReasonHint;

  /// No description provided for @expenseRequestCreatePaymentHint.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov turini tanlang'**
  String get expenseRequestCreatePaymentHint;

  /// No description provided for @expenseRequestCreateCardLabel.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get expenseRequestCreateCardLabel;

  /// No description provided for @expenseRequestCreateCardHint.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqamini kiriting'**
  String get expenseRequestCreateCardHint;

  /// No description provided for @expenseRequestCreateValidation.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, majburiy maydonlarni to\'ldiring.'**
  String get expenseRequestCreateValidation;

  /// No description provided for @expenseRequestCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov yuborildi.'**
  String get expenseRequestCreateSuccess;

  /// No description provided for @expenseRequestCreateSuccessMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovingiz muvaffaqiyatli yuborildi.'**
  String get expenseRequestCreateSuccessMessage;

  /// No description provided for @meetingCallJoinTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuvga qo‘shilish'**
  String get meetingCallJoinTitle;

  /// No description provided for @meetingCallWaitingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat kutilmoqda'**
  String get meetingCallWaitingTitle;

  /// No description provided for @meetingCallCameraOff.
  ///
  /// In uz, this message translates to:
  /// **'Kamera o‘chirilgan'**
  String get meetingCallCameraOff;

  /// No description provided for @meetingCallMicrophone.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofon'**
  String get meetingCallMicrophone;

  /// No description provided for @meetingCallCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get meetingCallCamera;

  /// No description provided for @meetingCallSampleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Haftalik loyiha yig‘ilishi'**
  String get meetingCallSampleTitle;

  /// No description provided for @meetingCallCodeCopied.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv kodi nusxalandi'**
  String get meetingCallCodeCopied;

  /// No description provided for @meetingCallJoin.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shilish'**
  String get meetingCallJoin;

  /// No description provided for @meetingCallApprovalHint.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi ruxsat bergach uchrashuvga kirasiz.'**
  String get meetingCallApprovalHint;

  /// No description provided for @meetingCallRequestSent.
  ///
  /// In uz, this message translates to:
  /// **'So‘rov yuborildi'**
  String get meetingCallRequestSent;

  /// No description provided for @meetingCallWaitingHint.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi ruxsat bergach avtomatik kirasiz.'**
  String get meetingCallWaitingHint;

  /// No description provided for @meetingCallCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get meetingCallCancel;

  /// No description provided for @meetingCallPreviewApprove.
  ///
  /// In uz, this message translates to:
  /// **'Demo: ruxsat berildi'**
  String get meetingCallPreviewApprove;

  /// No description provided for @meetingCallName.
  ///
  /// In uz, this message translates to:
  /// **'Meet nomi'**
  String get meetingCallName;

  /// No description provided for @meetingCallEnd.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni tugatish'**
  String get meetingCallEnd;

  /// No description provided for @meetingCallLeave.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get meetingCallLeave;

  /// No description provided for @meetingCallPinParticipant.
  ///
  /// In uz, this message translates to:
  /// **'Ekranga mahkamlash'**
  String get meetingCallPinParticipant;

  /// No description provided for @meetingCallUnpinParticipant.
  ///
  /// In uz, this message translates to:
  /// **'Mahkamlashni bekor qilish'**
  String get meetingCallUnpinParticipant;

  /// No description provided for @meetingCallYou.
  ///
  /// In uz, this message translates to:
  /// **'Siz'**
  String get meetingCallYou;

  /// No description provided for @meetingCallSelfName.
  ///
  /// In uz, this message translates to:
  /// **'Safarali Turotov (siz)'**
  String get meetingCallSelfName;

  /// No description provided for @meetingCallDilnoza.
  ///
  /// In uz, this message translates to:
  /// **'Dilnoza Sattorova'**
  String get meetingCallDilnoza;

  /// No description provided for @meetingCallBekzod.
  ///
  /// In uz, this message translates to:
  /// **'Bekzod Qodirov'**
  String get meetingCallBekzod;

  /// No description provided for @meetingCallRaisedNotice.
  ///
  /// In uz, this message translates to:
  /// **'Dilnoza Sattorova qo‘l ko‘tardi'**
  String get meetingCallRaisedNotice;

  /// No description provided for @meetingCallRaisedBy.
  ///
  /// In uz, this message translates to:
  /// **'{name} qo‘l ko‘tardi'**
  String meetingCallRaisedBy(Object name);

  /// No description provided for @meetingCallWantsToJoin.
  ///
  /// In uz, this message translates to:
  /// **'uchrashuvga qo‘shilmoqchi'**
  String get meetingCallWantsToJoin;

  /// No description provided for @meetingCallReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get meetingCallReject;

  /// No description provided for @meetingCallAllow.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get meetingCallAllow;

  /// No description provided for @meetingCallRaiseHand.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘l ko‘tarish'**
  String get meetingCallRaiseHand;

  /// No description provided for @meetingCallMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana'**
  String get meetingCallMore;

  /// No description provided for @meetingCallParticipantsCount.
  ///
  /// In uz, this message translates to:
  /// **'Ishtirokchilar (3)'**
  String get meetingCallParticipantsCount;

  /// No description provided for @meetingCallParticipants.
  ///
  /// In uz, this message translates to:
  /// **'Ishtirokchilar'**
  String get meetingCallParticipants;

  /// No description provided for @meetingCallChat.
  ///
  /// In uz, this message translates to:
  /// **'Chat'**
  String get meetingCallChat;

  /// No description provided for @meetingCallFeatureUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Bu funksiya hozircha mavjud emas.'**
  String get meetingCallFeatureUnavailable;

  /// No description provided for @meetingCallClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get meetingCallClose;

  /// No description provided for @meetingCallSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get meetingCallSearch;

  /// No description provided for @meetingCallInMeeting.
  ///
  /// In uz, this message translates to:
  /// **'UCHRASHUVDA'**
  String get meetingCallInMeeting;

  /// No description provided for @meetingCallOrganizer.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi'**
  String get meetingCallOrganizer;

  /// No description provided for @meetingCallParticipant.
  ///
  /// In uz, this message translates to:
  /// **'Ishtirokchi'**
  String get meetingCallParticipant;

  /// No description provided for @meetingCallChatNote.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlar uchrashuv tugagach o‘chiriladi.'**
  String get meetingCallChatNote;

  /// No description provided for @meetingCallSampleMessageOne.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotni ekranga chiqaring, iltimos'**
  String get meetingCallSampleMessageOne;

  /// No description provided for @meetingCallSampleMessageTwo.
  ///
  /// In uz, this message translates to:
  /// **'Bir daqiqa, ulashaman'**
  String get meetingCallSampleMessageTwo;

  /// No description provided for @meetingCallMessageHint.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yozing'**
  String get meetingCallMessageHint;

  /// No description provided for @meetingCallShareScreen.
  ///
  /// In uz, this message translates to:
  /// **'Ekranni ulashish'**
  String get meetingCallShareScreen;

  /// No description provided for @meetingCallScreenShareError.
  ///
  /// In uz, this message translates to:
  /// **'Ekran ulashib bo‘lmadi. Iltimos, qayta urinib ko‘ring.'**
  String get meetingCallScreenShareError;

  /// No description provided for @meetingCallStickers.
  ///
  /// In uz, this message translates to:
  /// **'Stikerlar'**
  String get meetingCallStickers;

  /// No description provided for @meetingCallMicAndSpeaker.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofon va dinamik'**
  String get meetingCallMicAndSpeaker;

  /// No description provided for @meetingCallMicrophoneSection.
  ///
  /// In uz, this message translates to:
  /// **'MIKROFON'**
  String get meetingCallMicrophoneSection;

  /// No description provided for @meetingCallSpeakerSection.
  ///
  /// In uz, this message translates to:
  /// **'DINAMIK'**
  String get meetingCallSpeakerSection;

  /// No description provided for @meetingCallDeviceUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma topilmadi'**
  String get meetingCallDeviceUnavailable;

  /// No description provided for @meetingCallDefaultDevice.
  ///
  /// In uz, this message translates to:
  /// **'Standart qurilma'**
  String get meetingCallDefaultDevice;

  /// No description provided for @meetingCallIphoneMicrophone.
  ///
  /// In uz, this message translates to:
  /// **'iPhone mikrofoni'**
  String get meetingCallIphoneMicrophone;

  /// No description provided for @meetingCallAirpods.
  ///
  /// In uz, this message translates to:
  /// **'AirPods Pro'**
  String get meetingCallAirpods;

  /// No description provided for @meetingCallWiredHeadset.
  ///
  /// In uz, this message translates to:
  /// **'Simli quloqchin'**
  String get meetingCallWiredHeadset;

  /// No description provided for @meetingCallIphoneSpeaker.
  ///
  /// In uz, this message translates to:
  /// **'iPhone dinamigi'**
  String get meetingCallIphoneSpeaker;

  /// No description provided for @meetingCallExitQuestion.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuvdan chiqasizmi?'**
  String get meetingCallExitQuestion;

  /// No description provided for @meetingCallExitHint.
  ///
  /// In uz, this message translates to:
  /// **'Havola amal qiladi, istalgan vaqtda qayta qo‘shilishingiz mumkin.'**
  String get meetingCallExitHint;

  /// No description provided for @meetingCallEndForEveryone.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni hamma uchun tugatish'**
  String get meetingCallEndForEveryone;

  /// No description provided for @meetingCallMeetingEndedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz uchrashuvdan chiqdingiz'**
  String get meetingCallMeetingEndedTitle;

  /// No description provided for @meetingCallMeetingEndedHint.
  ///
  /// In uz, this message translates to:
  /// **'Havola hali ham amal qiladi, istalgan vaqtda qaytishingiz mumkin.'**
  String get meetingCallMeetingEndedHint;

  /// No description provided for @meetingCallRejoin.
  ///
  /// In uz, this message translates to:
  /// **'Qayta qo‘shilish'**
  String get meetingCallRejoin;

  /// No description provided for @meetingCallHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifaga'**
  String get meetingCallHome;

  /// No description provided for @meetingCallDetails.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish tafsilotlari'**
  String get meetingCallDetails;

  /// No description provided for @meetingCallDetailsHint.
  ///
  /// In uz, this message translates to:
  /// **'Havola va rasmiy ma’lumotlar'**
  String get meetingCallDetailsHint;

  /// No description provided for @meetingCallJoinDetails.
  ///
  /// In uz, this message translates to:
  /// **'QO‘SHILISH MA’LUMOTLARI'**
  String get meetingCallJoinDetails;

  /// No description provided for @meetingCallMeetingLink.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish havolasi'**
  String get meetingCallMeetingLink;

  /// No description provided for @meetingCallMeetingParams.
  ///
  /// In uz, this message translates to:
  /// **'YIG‘ILISH PARAMETRLARI'**
  String get meetingCallMeetingParams;

  /// No description provided for @meetingCallOfficialUid.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiy UID'**
  String get meetingCallOfficialUid;

  /// No description provided for @meetingCallMeetingTopic.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish mavzusi'**
  String get meetingCallMeetingTopic;

  /// No description provided for @meetingCallStartTime.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish vaqti'**
  String get meetingCallStartTime;

  /// No description provided for @meetingCallSecurityAccess.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik va kirish'**
  String get meetingCallSecurityAccess;

  /// No description provided for @meetingCallDirectJoin.
  ///
  /// In uz, this message translates to:
  /// **'To‘g‘ridan-to‘g‘ri ulanish'**
  String get meetingCallDirectJoin;

  /// No description provided for @meetingCallMinutes.
  ///
  /// In uz, this message translates to:
  /// **'daqiqa'**
  String get meetingCallMinutes;

  /// No description provided for @meetingCallMeetingUid.
  ///
  /// In uz, this message translates to:
  /// **'MT-0005'**
  String get meetingCallMeetingUid;

  /// No description provided for @meetingCallTopicValue.
  ///
  /// In uz, this message translates to:
  /// **'Figmani ko‘rib chiqish'**
  String get meetingCallTopicValue;

  /// No description provided for @meetingCallStartValue.
  ///
  /// In uz, this message translates to:
  /// **'14.09.2026 15:40, 30 daqiqa'**
  String get meetingCallStartValue;

  /// No description provided for @meetingCallYouAreSharing.
  ///
  /// In uz, this message translates to:
  /// **'Siz ekranni ulashyapsiz'**
  String get meetingCallYouAreSharing;

  /// No description provided for @meetingCallStopSharing.
  ///
  /// In uz, this message translates to:
  /// **'Ulashishni to‘xtatish'**
  String get meetingCallStopSharing;

  /// No description provided for @meetingCallChooseAnotherScreen.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa ekranni tanlash'**
  String get meetingCallChooseAnotherScreen;

  /// No description provided for @meetingCallChatEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali xabar yo‘q'**
  String get meetingCallChatEmpty;

  /// No description provided for @meetingCallChatEmptyHint.
  ///
  /// In uz, this message translates to:
  /// **'Uchrashuv davomida yozishingiz mumkin'**
  String get meetingCallChatEmptyHint;

  /// No description provided for @meetingCallCameraAndBackground.
  ///
  /// In uz, this message translates to:
  /// **'Kamera va fon'**
  String get meetingCallCameraAndBackground;

  /// No description provided for @meetingCallCameraSection.
  ///
  /// In uz, this message translates to:
  /// **'KAMERA'**
  String get meetingCallCameraSection;

  /// No description provided for @meetingCallFrontCamera.
  ///
  /// In uz, this message translates to:
  /// **'Old kamera'**
  String get meetingCallFrontCamera;

  /// No description provided for @meetingCallRearCamera.
  ///
  /// In uz, this message translates to:
  /// **'Orqa kamera'**
  String get meetingCallRearCamera;

  /// No description provided for @meetingCallBackgroundSection.
  ///
  /// In uz, this message translates to:
  /// **'FON'**
  String get meetingCallBackgroundSection;

  /// No description provided for @meetingCallBlurBackground.
  ///
  /// In uz, this message translates to:
  /// **'Fonni xiralashtirish'**
  String get meetingCallBlurBackground;

  /// No description provided for @meetingCallNoBackground.
  ///
  /// In uz, this message translates to:
  /// **'Fonsiz'**
  String get meetingCallNoBackground;

  /// No description provided for @meetingCallOfficeBackgrounds.
  ///
  /// In uz, this message translates to:
  /// **'Ofis fonlari'**
  String get meetingCallOfficeBackgrounds;

  /// No description provided for @meetingCallSearchParticipant.
  ///
  /// In uz, this message translates to:
  /// **'Ishtirokchini qidirish'**
  String get meetingCallSearchParticipant;

  /// No description provided for @meetingCallMicRequestTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofonni yoqasizmi?'**
  String get meetingCallMicRequestTitle;

  /// No description provided for @meetingCallCameraRequestTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kamerani yoqasizmi?'**
  String get meetingCallCameraRequestTitle;

  /// No description provided for @meetingCallRequester.
  ///
  /// In uz, this message translates to:
  /// **'Safarali Turotov'**
  String get meetingCallRequester;

  /// No description provided for @meetingCallOrganizerRequested.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi, hozir so‘radi'**
  String get meetingCallOrganizerRequested;

  /// No description provided for @meetingCallMicRequestHint.
  ///
  /// In uz, this message translates to:
  /// **'Qaror sizniki. Tayyor bo‘lmasangiz, keyinroq o‘zingiz yoqishingiz mumkin.'**
  String get meetingCallMicRequestHint;

  /// No description provided for @meetingCallCameraRequestHint.
  ///
  /// In uz, this message translates to:
  /// **'Qaror sizniki. Istamasangiz, kamerani o‘chiq qoldiring.'**
  String get meetingCallCameraRequestHint;

  /// No description provided for @meetingCallNotNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yo‘q'**
  String get meetingCallNotNow;

  /// No description provided for @meetingCallEnableMicrophone.
  ///
  /// In uz, this message translates to:
  /// **'Mikrofonni yoqish'**
  String get meetingCallEnableMicrophone;

  /// No description provided for @meetingCallEnableCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamerani yoqish'**
  String get meetingCallEnableCamera;

  /// No description provided for @meetingCallStickersTitle.
  ///
  /// In uz, this message translates to:
  /// **'Stikerlar'**
  String get meetingCallStickersTitle;

  /// No description provided for @meetingCallStickersDuration.
  ///
  /// In uz, this message translates to:
  /// **'3 soniya ko‘rinadi'**
  String get meetingCallStickersDuration;

  /// No description provided for @meetingCallCloseStickers.
  ///
  /// In uz, this message translates to:
  /// **'Stikerlar panelini yopish'**
  String get meetingCallCloseStickers;

  /// No description provided for @meetingCallSendMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuborish'**
  String get meetingCallSendMessage;

  /// No description provided for @meetingCallLateReason.
  ///
  /// In uz, this message translates to:
  /// **'Kechikish: {minutes} daqiqa'**
  String meetingCallLateReason(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
