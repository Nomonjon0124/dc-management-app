import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  // ── Base ──────────────────────────────────────────────────────────────
  final Color white;
  final Color black;
  final Color shadow;

  // ── Background ────────────────────────────────────────────────────────
  final Color backgroundBase;
  final Color backgroundBase2;
  final Color backgroundElevation1;
  final Color backgroundElevation1Alt;
  final Color backgroundElevation2;
  final Color backgroundElevation2Alt;
  final Color backgroundElevation3;
  final Color backgroundElevation3Alt;

  // ── Accent ────────────────────────────────────────────────────────────
  final Color accentStrong;
  final Color accentSub;
  final Color accentSoft;
  final Color accentDisabled;
  final Color accentWhite;

  // ── Text ──────────────────────────────────────────────────────────────
  final Color textStrong;
  final Color textSub;
  final Color textSoft;
  final Color textDisabled;
  final Color textWhite;
  final Color textAccent;
  final Color textInWhite;
  final Color textInDark;

  // ── Stroke ────────────────────────────────────────────────────────────
  final Color strokeStrong;
  final Color strokeSub;
  final Color strokeSoft;
  final Color strokeAccent;
  final Color strokeWhite;

  // ── Icon ──────────────────────────────────────────────────────────────
  final Color iconStrong;
  final Color iconSub;
  final Color iconSoft;
  final Color iconDisabled;
  final Color iconWhite;
  final Color iconAccent;
  final Color iconInWhite;
  final Color iconInBlack;

  /// Bildirishnoma ikonkasi (masalan expense AppBar SVG).
  final Color iconNotify;

  // ── Error ─────────────────────────────────────────────────────────────
  final Color errorStrong;
  final Color errorSub;
  final Color errorSoft;
  final Color errorDisabled;

  // ── Success ───────────────────────────────────────────────────────────
  final Color successStrong;
  final Color successPrimary;
  final Color successSub;
  final Color successSoft;
  final Color successDisabled;

  // ── Chart (bosh sahifa grafiklari data-vis tokenlari) ─────────────────
  /// Loyihalar bar: "Tugatilgan" (yashil-limon).
  final Color chartLime;

  /// Loyihalar bar: "Jarayonda" (moviy-yashil / teal).
  final Color chartTeal;

  /// Loyihalar bar: "Bekor" (to‘q neytral).
  final Color chartNeutral;

  /// Loyihalar bar: "Rejalashtirilgan" (och kulrang).
  final Color chartGrey;

  /// Yig‘ilishlar donut: "Qatnashdi" (yashil).
  final Color chartGreen;

  /// Yig‘ilishlar donut: "Sababli" (ko‘k).
  final Color chartBlue;

  // ── Task priority / status (vazifa kartasi tokenlari) ─────────────────
  /// Muhimlik "Past" pill foni.
  final Color taskPriorityLow;

  /// Muhimlik "O‘rta" pill foni.
  final Color taskPriorityMedium;

  /// Muhimlik "Yuqori" pill foni.
  final Color taskPriorityHigh;

  /// Muhimlik "Kritik" pill foni.
  final Color taskPriorityCritical;

  /// "Qilinishi kerak" holati nuqtasi (amber).
  final Color taskStatusTodo;

  /// "Jarayonda" holati nuqtasi (ko‘k).
  final Color taskStatusInProgress;

  /// "Muddati o‘tgan" holati nuqtasi (kulrang).
  final Color taskStatusOverdue;

  /// "Bajarildi" holati nuqtasi (binafsha).
  final Color taskStatusDone;

  /// "Ishga tushirildi" holati nuqtasi (yashil).
  final Color taskStatusProduction;

  /// "Tekshirildi" holati nuqtasi (to‘q sariq).
  final Color taskStatusChecked;

  /// "Rad etildi" holati nuqtasi (qizil).
  final Color taskStatusRejected;

  /// Connected meeting room'dagi self tile foni.
  final Color meetingLocalTile;

  // ── Daily plans ─────────────────────────────────────────────────────────
  final Color dailyPlanRed;
  final Color dailyPlanYellow;
  final Color dailyPlanGreen;
  final Color dailyPlanBlue;

  /// Xarajat kartasi va shunga o‘xshash bosh harf avatarlari uchun fon.
  final Color avatarPlaceholder;

  /// Bildirishnoma avataridagi "o‘qilgan" nishoni (ko‘k check).
  final Color badgeRead;

  /// Bildirishnoma avataridagi "o‘qilmagan" nishoni (to‘q sariq son).
  final Color badgeUnread;

  // ── Control (input / button komponent tokenlari) ──────────────────────
  /// Input placeholder / ikkilamchi yozuv (Figma: components/control/text/secondary).
  final Color controlTextSecondary;

  /// O‘chirilgan tugma yozuvi (Figma: components/control/text/disabled).
  final Color controlTextDisabled;

  /// O‘chirilgan tugma foni (Figma: components/control/bg/disabled).
  final Color controlBgDisabled;

  const AppColors({
    required this.white,
    required this.black,
    required this.shadow,
    required this.backgroundBase,
    required this.backgroundBase2,
    required this.backgroundElevation1,
    required this.backgroundElevation1Alt,
    required this.backgroundElevation2,
    required this.backgroundElevation2Alt,
    required this.backgroundElevation3,
    required this.backgroundElevation3Alt,
    required this.accentStrong,
    required this.accentSub,
    required this.accentSoft,
    required this.accentDisabled,
    required this.accentWhite,
    required this.textStrong,
    required this.textSub,
    required this.textSoft,
    required this.textDisabled,
    required this.textWhite,
    required this.textAccent,
    required this.textInWhite,
    required this.textInDark,
    required this.strokeStrong,
    required this.strokeSub,
    required this.strokeSoft,
    required this.strokeAccent,
    required this.strokeWhite,
    required this.iconStrong,
    required this.iconSub,
    required this.iconSoft,
    required this.iconDisabled,
    required this.iconWhite,
    required this.iconAccent,
    required this.iconInWhite,
    required this.iconInBlack,
    required this.iconNotify,
    required this.errorStrong,
    required this.errorSub,
    required this.errorSoft,
    required this.errorDisabled,
    required this.successStrong,
    required this.successPrimary,
    required this.successSub,
    required this.successSoft,
    required this.successDisabled,
    required this.chartLime,
    required this.chartTeal,
    required this.chartNeutral,
    required this.chartGrey,
    required this.chartGreen,
    required this.chartBlue,
    required this.taskPriorityLow,
    required this.taskPriorityMedium,
    required this.taskPriorityHigh,
    required this.taskPriorityCritical,
    required this.taskStatusTodo,
    required this.taskStatusInProgress,
    required this.taskStatusOverdue,
    required this.taskStatusDone,
    required this.taskStatusProduction,
    required this.taskStatusChecked,
    required this.taskStatusRejected,
    required this.meetingLocalTile,
    required this.dailyPlanRed,
    required this.dailyPlanYellow,
    required this.dailyPlanGreen,
    required this.dailyPlanBlue,
    required this.avatarPlaceholder,
    required this.badgeRead,
    required this.badgeUnread,
    required this.controlTextSecondary,
    required this.controlTextDisabled,
    required this.controlBgDisabled,
  });

  factory AppColors.light() => const AppColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    shadow: Color(0x1F000000), // alpha 0.12
    backgroundBase: Color(0xFFFFFFFF),
    backgroundBase2: Color(0xFFFFFFFF),
    backgroundElevation1: Color(0xFFF8F9FC),
    backgroundElevation1Alt: Color(0xFFF1F3F9),
    backgroundElevation2: Color(0xFFE9ECF5),
    backgroundElevation2Alt: Color(0xFFE2E6F2),
    backgroundElevation3: Color(0xFFDADFF0),
    backgroundElevation3Alt: Color(0xFFD2D8EC),
    accentStrong: Color(0xFF3F57B3),
    accentSub: Color(0xFF526ED3),
    accentSoft: Color(0xFF7F95E6),
    accentDisabled: Color(0xFFE9EEFF),
    accentWhite: Color(0xFFFFFFFF),
    textStrong: Color(0xFF1A1D2E),
    textSub: Color(0xFF5B6078),
    textSoft: Color(0xFF8F95A8),
    textDisabled: Color(0xFFB6BCCB),
    textWhite: Color(0xFFFFFFFF),
    textAccent: Color(0xFF526ED3),
    textInWhite: Color(0xFFFFFFFF),
    textInDark: Color(0xFF000000),
    strokeStrong: Color(0xFFD0D5E2),
    strokeSub: Color(0xFFE2E6F2),
    strokeSoft: Color(0xFFEEF1F7),
    strokeAccent: Color(0xFF526ED3),
    strokeWhite: Color(0xFFFFFFFF),
    iconStrong: Color(0xFF1A1D2E),
    iconSub: Color(0xFF5B6078),
    iconSoft: Color(0xFF141B34),
    iconDisabled: Color(0xFFC5CAD8),
    iconWhite: Color(0xFFFFFFFF),
    iconAccent: Color(0xFF526ED3),
    iconInWhite: Color(0xFFFFFFFF),
    iconInBlack: Color(0xFF000000),
    iconNotify: Color(0xFF000000),
    errorStrong: Color(0xFFE02D2D),
    errorSub: Color(0xFFFA5252),
    errorSoft: Color(0xFF2E1A1A),
    errorDisabled: Color(0xFFF8D7DA),
    successStrong: Color(0xFF22C55E),
    successPrimary: Color(0xFF02D15C),
    successSub: Color(0xFF4ADE80),
    successSoft: Color(0xFFDCFCE7),
    successDisabled: Color(0xFFF0FDF4),
    chartLime: Color(0xFFA5CE1B),
    chartTeal: Color(0xFF7EC3BE),
    chartNeutral: Color(0xFF1A1D2E),
    chartGrey: Color(0xFFDADFF0),
    chartGreen: Color(0xFF2DBE2C),
    chartBlue: Color(0xFF92BFFF),
    taskPriorityLow: Color(0xFF888780),
    taskPriorityMedium: Color(0xFFED9121),
    taskPriorityHigh: Color(0xFF185FA5),
    taskPriorityCritical: Color(0xFFE24B4A),
    taskStatusTodo: Color(0xFFFBC02D),
    taskStatusInProgress: Color(0xFF1E88E5),
    taskStatusOverdue: Color(0xFF616161),
    taskStatusDone: Color(0xFF5E35B1),
    taskStatusProduction: Color(0xFF43A047),
    taskStatusChecked: Color(0xFFFB8C00),
    taskStatusRejected: Color(0xFFE53935),
    meetingLocalTile: Color(0xFF0F111C),
    dailyPlanRed: Color(0xFFEF161E),
    dailyPlanYellow: Color(0xFFFFD702),
    dailyPlanGreen: Color(0xFF2DBE2C),
    dailyPlanBlue: Color(0xFF005FF9),
    avatarPlaceholder: Color(0xFFDADFF0),
    badgeRead: Color(0xFF526ED3),
    badgeUnread: Color(0xFFFF6A2E),
    controlTextSecondary: Color(0xFF757575),
    controlTextDisabled: Color(0xFFA3A3A3),
    controlBgDisabled: Color(0xFFF2F1F0),
  );

  factory AppColors.dark() => const AppColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    shadow: Color(0x3D000000), // alpha 0.24
    backgroundBase: Color(0xFF000000),
    backgroundBase2: Color(0xFF111111),
    backgroundElevation1: Color(0xFF161B22),
    backgroundElevation1Alt: Color(0xFF1C2128),
    backgroundElevation2: Color(0xFFE9ECF5),
    backgroundElevation2Alt: Color(0xFF303131),
    backgroundElevation3: Color(0xFF3A3B3B),
    backgroundElevation3Alt: Color(0xFF474848),
    accentStrong: Color(0xFF2B3553),
    accentSub: Color(0xFF344064),
    accentSoft: Color(0xFF7F95E6),
    accentDisabled: Color(0xFF1E2B5C),
    accentWhite: Color(0xFFFFFFFF),
    textStrong: Color(0xFFE6EDF3),
    textSub: Color(0xFFC2C8E0),
    textSoft: Color(0xFF8E95B5),
    textDisabled: Color(0xFF5C627D),
    textWhite: Color(0xFFFFFFFF),
    textAccent: Color(0xFF7F95E6),
    textInWhite: Color(0xFFFFFFFF),
    textInDark: Color(0xFF000000),
    strokeStrong: Color(0xFF191A1A),
    strokeSub: Color(0xFF262C36),
    strokeSoft: Color(0xFF474848),
    strokeAccent: Color(0xFF7F95E6),
    strokeWhite: Color(0xFFFFFFFF),
    iconStrong: Color(0xFFFFFFFF),
    iconSub: Color(0xFFC2C8E0),
    iconSoft: Color(0xFFC2C8E0),
    iconDisabled: Color(0xFF5C627D),
    iconWhite: Color(0xFFFFFFFF),
    iconAccent: Color(0xFF7F95E6),
    iconInWhite: Color(0xFFFFFFFF),
    iconInBlack: Color(0xFF000000),
    iconNotify: Color(0xFFFFFFFF),
    errorStrong: Color(0xFFE02D2D),
    errorSub: Color(0xFFFA5252),
    errorSoft: Color(0xFFFFF2F2),
    errorDisabled: Color(0xFF402323),
    successStrong: Color(0xFF22C55E),
    successPrimary: Color(0xFF02D15C),
    successSub: Color(0xFF4ADE80),
    successSoft: Color(0xFF142E1B),
    successDisabled: Color(0xFF1B3D24),
    chartLime: Color(0xFFA5CE1B),
    chartTeal: Color(0xFF7EC3BE),
    chartNeutral: Color(0xFF2C2A2A),
    chartGrey: Color(0xFFCED2DC),
    chartGreen: Color(0xFF2DBE2C),
    chartBlue: Color(0xFF92BFFF),
    taskPriorityLow: Color(0xFF888780),
    taskPriorityMedium: Color(0xFFED9121),
    taskPriorityHigh: Color(0xFF185FA5),
    taskPriorityCritical: Color(0xFFE24B4A),
    taskStatusTodo: Color(0xFFFBC02D),
    taskStatusInProgress: Color(0xFF1E88E5),
    taskStatusOverdue: Color(0xFF616161),
    taskStatusDone: Color(0xFF5E35B1),
    taskStatusProduction: Color(0xFF43A047),
    taskStatusChecked: Color(0xFFFB8C00),
    taskStatusRejected: Color(0xFFE53935),
    meetingLocalTile: Color(0xFF0F111C),
    dailyPlanRed: Color(0xFFEF161E),
    dailyPlanYellow: Color(0xFFFFD702),
    dailyPlanGreen: Color(0xFF2DBE2C),
    dailyPlanBlue: Color(0xFF005FF9),
    avatarPlaceholder: Color(0xFF3A3B3B),
    badgeRead: Color(0xFF526ED3),
    badgeUnread: Color(0xFFFF6A2E),
    controlTextSecondary: Color(0xFF757575),
    controlTextDisabled: Color(0xFFA3A3A3),
    controlBgDisabled: Color(0xFFF2F1F0),
  );

  /// Auth gradienti ustidagi matn rangi (sarlavha + tavsif).
  /// Gradient har ikkala rejimda ham OCH — shu sabab matn doim TO‘Q bo‘ladi
  /// (tema rejimiga bog‘liq emas).
  static const Color authForeground = Color(0xFF1A1D2E);

  /// Auth/login fon gradienti (Figma: 95.84°, oqish-binafsha → ko‘k).
  /// Brend gradienti — har ikkala rejimda ham bir xil.
  static const Gradient authBackgroundGradient = LinearGradient(
    begin: Alignment(-1.0, -0.1),
    end: Alignment(1.0, 0.1),
    colors: [Color(0xFFE6ECFF), Color(0xFFA5B4FC), Color(0xFF6E86E1)],
    stops: [0.0025, 0.3575, 1.0],
  );

  /// Access from anywhere: `Theme.of(context).extension<AppColors>()!`
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  /// Grafik kartasi foni (light: `backgroundElevation1Alt`, dark: `backgroundElevation1`).
  Color get cardSurface => backgroundBase.computeLuminance() < 0.5
      ? backgroundElevation1
      : backgroundElevation1Alt;

  /// Dialog/toast ustidagi yuza foni — sahifa fonidan (base) ajralib turishi
  /// uchun. Dark rejimda `backgroundBase` qora bo'lib, dialog/toast page bilan
  /// qorishib ketardi; shu bois dark'da ko'tarilgan yuza ishlatiladi. Light —
  /// oq (base bilan bir xil, dizayn shunday).
  Color get overlaySurface => backgroundBase.computeLuminance() < 0.5
      ? backgroundElevation1
      : backgroundBase;

  /// Xarajatlar AppBar filtr/bildirishnoma tugmasi foni (light: `backgroundElevation2`, dark: `strokeSub`).
  Color get expenseAppBarFilterSurface =>
      backgroundBase.computeLuminance() < 0.5
      ? strokeSub
      : backgroundElevation2;

  @override
  AppColors copyWith({
    Color? white,
    Color? black,
    Color? shadow,
    Color? backgroundBase,
    Color? backgroundBase2,
    Color? backgroundElevation1,
    Color? backgroundElevation1Alt,
    Color? backgroundElevation2,
    Color? backgroundElevation2Alt,
    Color? backgroundElevation3,
    Color? backgroundElevation3Alt,
    Color? accentStrong,
    Color? accentSub,
    Color? accentSoft,
    Color? accentDisabled,
    Color? accentWhite,
    Color? textStrong,
    Color? textSub,
    Color? textSoft,
    Color? textDisabled,
    Color? textWhite,
    Color? textAccent,
    Color? textInWhite,
    Color? textInDark,
    Color? strokeStrong,
    Color? strokeSub,
    Color? strokeSoft,
    Color? strokeAccent,
    Color? strokeWhite,
    Color? iconStrong,
    Color? iconSub,
    Color? iconSoft,
    Color? iconDisabled,
    Color? iconWhite,
    Color? iconAccent,
    Color? iconInWhite,
    Color? iconInBlack,
    Color? iconNotify,
    Color? errorStrong,
    Color? errorSub,
    Color? errorSoft,
    Color? errorDisabled,
    Color? successStrong,
    Color? successPrimary,
    Color? successSub,
    Color? successSoft,
    Color? successDisabled,
    Color? chartLime,
    Color? chartTeal,
    Color? chartNeutral,
    Color? chartGrey,
    Color? chartGreen,
    Color? chartBlue,
    Color? taskPriorityLow,
    Color? taskPriorityMedium,
    Color? taskPriorityHigh,
    Color? taskPriorityCritical,
    Color? taskStatusTodo,
    Color? taskStatusInProgress,
    Color? taskStatusOverdue,
    Color? taskStatusDone,
    Color? taskStatusProduction,
    Color? taskStatusChecked,
    Color? taskStatusRejected,
    Color? meetingLocalTile,
    Color? dailyPlanRed,
    Color? dailyPlanYellow,
    Color? dailyPlanGreen,
    Color? dailyPlanBlue,
    Color? avatarPlaceholder,
    Color? badgeRead,
    Color? badgeUnread,
    Color? controlTextSecondary,
    Color? controlTextDisabled,
    Color? controlBgDisabled,
  }) => AppColors(
    white: white ?? this.white,
    black: black ?? this.black,
    shadow: shadow ?? this.shadow,
    backgroundBase: backgroundBase ?? this.backgroundBase,
    backgroundBase2: backgroundBase2 ?? this.backgroundBase2,
    backgroundElevation1: backgroundElevation1 ?? this.backgroundElevation1,
    backgroundElevation1Alt:
        backgroundElevation1Alt ?? this.backgroundElevation1Alt,
    backgroundElevation2: backgroundElevation2 ?? this.backgroundElevation2,
    backgroundElevation2Alt:
        backgroundElevation2Alt ?? this.backgroundElevation2Alt,
    backgroundElevation3: backgroundElevation3 ?? this.backgroundElevation3,
    backgroundElevation3Alt:
        backgroundElevation3Alt ?? this.backgroundElevation3Alt,
    accentStrong: accentStrong ?? this.accentStrong,
    accentSub: accentSub ?? this.accentSub,
    accentSoft: accentSoft ?? this.accentSoft,
    accentDisabled: accentDisabled ?? this.accentDisabled,
    accentWhite: accentWhite ?? this.accentWhite,
    textStrong: textStrong ?? this.textStrong,
    textSub: textSub ?? this.textSub,
    textSoft: textSoft ?? this.textSoft,
    textDisabled: textDisabled ?? this.textDisabled,
    textWhite: textWhite ?? this.textWhite,
    textAccent: textAccent ?? this.textAccent,
    textInWhite: textInWhite ?? this.textInWhite,
    textInDark: textInDark ?? this.textInDark,
    strokeStrong: strokeStrong ?? this.strokeStrong,
    strokeSub: strokeSub ?? this.strokeSub,
    strokeSoft: strokeSoft ?? this.strokeSoft,
    strokeAccent: strokeAccent ?? this.strokeAccent,
    strokeWhite: strokeWhite ?? this.strokeWhite,
    iconStrong: iconStrong ?? this.iconStrong,
    iconSub: iconSub ?? this.iconSub,
    iconSoft: iconSoft ?? this.iconSoft,
    iconDisabled: iconDisabled ?? this.iconDisabled,
    iconWhite: iconWhite ?? this.iconWhite,
    iconAccent: iconAccent ?? this.iconAccent,
    iconInWhite: iconInWhite ?? this.iconInWhite,
    iconInBlack: iconInBlack ?? this.iconInBlack,
    iconNotify: iconNotify ?? this.iconNotify,
    errorStrong: errorStrong ?? this.errorStrong,
    errorSub: errorSub ?? this.errorSub,
    errorSoft: errorSoft ?? this.errorSoft,
    errorDisabled: errorDisabled ?? this.errorDisabled,
    successStrong: successStrong ?? this.successStrong,
    successPrimary: successPrimary ?? this.successPrimary,
    successSub: successSub ?? this.successSub,
    successSoft: successSoft ?? this.successSoft,
    successDisabled: successDisabled ?? this.successDisabled,
    chartLime: chartLime ?? this.chartLime,
    chartTeal: chartTeal ?? this.chartTeal,
    chartNeutral: chartNeutral ?? this.chartNeutral,
    chartGrey: chartGrey ?? this.chartGrey,
    chartGreen: chartGreen ?? this.chartGreen,
    chartBlue: chartBlue ?? this.chartBlue,
    taskPriorityLow: taskPriorityLow ?? this.taskPriorityLow,
    taskPriorityMedium: taskPriorityMedium ?? this.taskPriorityMedium,
    taskPriorityHigh: taskPriorityHigh ?? this.taskPriorityHigh,
    taskPriorityCritical: taskPriorityCritical ?? this.taskPriorityCritical,
    taskStatusTodo: taskStatusTodo ?? this.taskStatusTodo,
    taskStatusInProgress: taskStatusInProgress ?? this.taskStatusInProgress,
    taskStatusOverdue: taskStatusOverdue ?? this.taskStatusOverdue,
    taskStatusDone: taskStatusDone ?? this.taskStatusDone,
    taskStatusProduction: taskStatusProduction ?? this.taskStatusProduction,
    taskStatusChecked: taskStatusChecked ?? this.taskStatusChecked,
    taskStatusRejected: taskStatusRejected ?? this.taskStatusRejected,
    meetingLocalTile: meetingLocalTile ?? this.meetingLocalTile,
    dailyPlanRed: dailyPlanRed ?? this.dailyPlanRed,
    dailyPlanYellow: dailyPlanYellow ?? this.dailyPlanYellow,
    dailyPlanGreen: dailyPlanGreen ?? this.dailyPlanGreen,
    dailyPlanBlue: dailyPlanBlue ?? this.dailyPlanBlue,
    avatarPlaceholder: avatarPlaceholder ?? this.avatarPlaceholder,
    badgeRead: badgeRead ?? this.badgeRead,
    badgeUnread: badgeUnread ?? this.badgeUnread,
    controlTextSecondary: controlTextSecondary ?? this.controlTextSecondary,
    controlTextDisabled: controlTextDisabled ?? this.controlTextDisabled,
    controlBgDisabled: controlBgDisabled ?? this.controlBgDisabled,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundBase2: Color.lerp(backgroundBase2, other.backgroundBase2, t)!,
      backgroundElevation1: Color.lerp(
        backgroundElevation1,
        other.backgroundElevation1,
        t,
      )!,
      backgroundElevation1Alt: Color.lerp(
        backgroundElevation1Alt,
        other.backgroundElevation1Alt,
        t,
      )!,
      backgroundElevation2: Color.lerp(
        backgroundElevation2,
        other.backgroundElevation2,
        t,
      )!,
      backgroundElevation2Alt: Color.lerp(
        backgroundElevation2Alt,
        other.backgroundElevation2Alt,
        t,
      )!,
      backgroundElevation3: Color.lerp(
        backgroundElevation3,
        other.backgroundElevation3,
        t,
      )!,
      backgroundElevation3Alt: Color.lerp(
        backgroundElevation3Alt,
        other.backgroundElevation3Alt,
        t,
      )!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSub: Color.lerp(accentSub, other.accentSub, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentDisabled: Color.lerp(accentDisabled, other.accentDisabled, t)!,
      accentWhite: Color.lerp(accentWhite, other.accentWhite, t)!,
      textStrong: Color.lerp(textStrong, other.textStrong, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textInWhite: Color.lerp(textInWhite, other.textInWhite, t)!,
      textInDark: Color.lerp(textInDark, other.textInDark, t)!,
      strokeStrong: Color.lerp(strokeStrong, other.strokeStrong, t)!,
      strokeSub: Color.lerp(strokeSub, other.strokeSub, t)!,
      strokeSoft: Color.lerp(strokeSoft, other.strokeSoft, t)!,
      strokeAccent: Color.lerp(strokeAccent, other.strokeAccent, t)!,
      strokeWhite: Color.lerp(strokeWhite, other.strokeWhite, t)!,
      iconStrong: Color.lerp(iconStrong, other.iconStrong, t)!,
      iconSub: Color.lerp(iconSub, other.iconSub, t)!,
      iconSoft: Color.lerp(iconSoft, other.iconSoft, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      iconWhite: Color.lerp(iconWhite, other.iconWhite, t)!,
      iconAccent: Color.lerp(iconAccent, other.iconAccent, t)!,
      iconInWhite: Color.lerp(iconInWhite, other.iconInWhite, t)!,
      iconInBlack: Color.lerp(iconInBlack, other.iconInBlack, t)!,
      iconNotify: Color.lerp(iconNotify, other.iconNotify, t)!,
      errorStrong: Color.lerp(errorStrong, other.errorStrong, t)!,
      errorSub: Color.lerp(errorSub, other.errorSub, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      errorDisabled: Color.lerp(errorDisabled, other.errorDisabled, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      successPrimary: Color.lerp(successPrimary, other.successPrimary, t)!,
      successSub: Color.lerp(successSub, other.successSub, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successDisabled: Color.lerp(successDisabled, other.successDisabled, t)!,
      chartLime: Color.lerp(chartLime, other.chartLime, t)!,
      chartTeal: Color.lerp(chartTeal, other.chartTeal, t)!,
      chartNeutral: Color.lerp(chartNeutral, other.chartNeutral, t)!,
      chartGrey: Color.lerp(chartGrey, other.chartGrey, t)!,
      chartGreen: Color.lerp(chartGreen, other.chartGreen, t)!,
      chartBlue: Color.lerp(chartBlue, other.chartBlue, t)!,
      taskPriorityLow: Color.lerp(taskPriorityLow, other.taskPriorityLow, t)!,
      taskPriorityMedium: Color.lerp(
        taskPriorityMedium,
        other.taskPriorityMedium,
        t,
      )!,
      taskPriorityHigh: Color.lerp(
        taskPriorityHigh,
        other.taskPriorityHigh,
        t,
      )!,
      taskPriorityCritical: Color.lerp(
        taskPriorityCritical,
        other.taskPriorityCritical,
        t,
      )!,
      taskStatusTodo: Color.lerp(taskStatusTodo, other.taskStatusTodo, t)!,
      taskStatusInProgress: Color.lerp(
        taskStatusInProgress,
        other.taskStatusInProgress,
        t,
      )!,
      taskStatusOverdue: Color.lerp(
        taskStatusOverdue,
        other.taskStatusOverdue,
        t,
      )!,
      taskStatusDone: Color.lerp(taskStatusDone, other.taskStatusDone, t)!,
      taskStatusProduction: Color.lerp(
        taskStatusProduction,
        other.taskStatusProduction,
        t,
      )!,
      taskStatusChecked: Color.lerp(
        taskStatusChecked,
        other.taskStatusChecked,
        t,
      )!,
      taskStatusRejected: Color.lerp(
        taskStatusRejected,
        other.taskStatusRejected,
        t,
      )!,
      meetingLocalTile: Color.lerp(
        meetingLocalTile,
        other.meetingLocalTile,
        t,
      )!,
      dailyPlanRed: Color.lerp(dailyPlanRed, other.dailyPlanRed, t)!,
      dailyPlanYellow: Color.lerp(dailyPlanYellow, other.dailyPlanYellow, t)!,
      dailyPlanGreen: Color.lerp(dailyPlanGreen, other.dailyPlanGreen, t)!,
      dailyPlanBlue: Color.lerp(dailyPlanBlue, other.dailyPlanBlue, t)!,
      avatarPlaceholder: Color.lerp(
        avatarPlaceholder,
        other.avatarPlaceholder,
        t,
      )!,
      badgeRead: Color.lerp(badgeRead, other.badgeRead, t)!,
      badgeUnread: Color.lerp(badgeUnread, other.badgeUnread, t)!,
      controlTextSecondary: Color.lerp(
        controlTextSecondary,
        other.controlTextSecondary,
        t,
      )!,
      controlTextDisabled: Color.lerp(
        controlTextDisabled,
        other.controlTextDisabled,
        t,
      )!,
      controlBgDisabled: Color.lerp(
        controlBgDisabled,
        other.controlBgDisabled,
        t,
      )!,
    );
  }
}
