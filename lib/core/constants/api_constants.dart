abstract final class ApiConstants {
  static const baseUrl = 'https://backend.raqamlinazorat.uz/api';

  /// Real-vaqt bildirishnomalar uchun WebSocket ildizi (https → wss).
  static const wsBaseUrl = 'wss://backend.raqamlinazorat.uz';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/auth/login/';
  static const refresh = '/auth/refresh/';

  // ── Profile ───────────────────────────────────────────────────────────
  static const usersMe = '/users/me/';
  static const usersMeChangePassword = '/users/me/change-password/';

  // ── Statistics (bosh sahifa grafiklari) ───────────────────────────────
  static const usersMePeriodStatistics = '/users/me/period-statistics/';

  // ── Notifications ─────────────────────────────────────────────────────
  static const notifications = '/notifications/';
  static const notificationsCount = '/notifications/count/';
  static const notificationsReadAll = '/notifications/read-all/';
  static const notificationsTickets = '/notifications/tickets/';

  /// Bitta bildirishnomani o‘qilgan deb belgilash: `/notifications/{id}/read/`.
  static String notificationRead(int id) => '/notifications/$id/read/';

  /// Bildirishnoma WebSocket ulanish URL’i (bir martalik ticket bilan).
  static String notificationsSocket(String ticket) =>
      '$wsBaseUrl/ws/notifications/?ticket=$ticket';

  /// Meeting-specific orchestration socket. The meeting contract uses the
  /// `/api/ws/meetings/` prefix, unlike the existing global notification WS.
  static String meetingSocket(int meetingId, String ticket) =>
      '$wsBaseUrl/api/ws/meetings/$meetingId/?ticket=$ticket';

  // ── Device (FCM) ──────────────────────────────────────────────────────
  /// Qurilmani FCM token bilan ro‘yxatdan o‘tkazish (`POST`).
  static const devicesRegister = '/devices/register/';

  // ── User Reports ──────────────────────────────────────────────────────
  static const reportsUsers = '/reports/users/';

  // ── Project Reports ───────────────────────────────────────────────────
  static const reportsProjects = '/reports/projects/';

  // ── Expense Reports ────────────────────────────────────────────────────
  static const reportsExpenses = '/reports/expenses/';
  static const expenseCategories = '/expense-category/';

  // ── Task Reports ───────────────────────────────────────────────────────
  static const reportsTasks = '/reports/tasks/';

  // ── Payroll Reports ────────────────────────────────────────────────────
  static const reportsPayrolls = '/reports/payrolls/';

  /// Viloyatlar — hisobot filtri "Viloyat" tanlovi (`GET /applications/regions/`).
  static const applicationsRegions = '/applications/regions/';
  static const applicationsDistricts = '/applications/districts/';

  // ── Tasks ─────────────────────────────────────────────────────────────
  static const tasks = '/tasks/';

  /// Bitta vazifa: `GET/PUT/PATCH/DELETE /tasks/{id}/`.
  static String taskById(int id) => '/tasks/$id/';

  // ── Daily plans ──────────────────────────────────────────────────────────
  static const todos = '/todos/';
  static String todoById(int id) => '/todos/$id/';
  static const todoItems = '/todo-items/';
  static String todoItemById(int id) => '/todo-items/$id/';

  /// Lavozimlar — vazifa "Kimlar uchun" tanlovi (`GET /applications/positions/`).
  static const positions = '/applications/positions/';

  /// Qisqa loyihalar ro‘yxati — vazifa "Loyiha" tanlovi (`GET /project-shorts/`).
  static const projectShorts = '/project-shorts/';

  static String projectShortById(int id) => '/project-shorts/$id/';

  /// Barcha foydalanuvchilar (qisqa) — filtr "Muallif"/"Xodim" tanlovi
  /// (`GET /users/all/`).
  static const usersAll = '/users/all/';
  static const users = '/users/';

  /// Bitta foydalanuvchi: `GET/PUT/PATCH/DELETE /users/{id}/`.
  static String userById(int id) => '/users/$id/';

  // ── Ledger (moliya tarixi) ────────────────────────────────────────────
  static const ledger = '/ledger/';

  /// Bitta tarix yozuvi: `GET /ledger/{id}/`.
  static String ledgerById(int id) => '/ledger/$id/';

  // ── Payroll (ish haqi) ────────────────────────────────────────────────
  static const payroll = '/payroll/';

  /// Bitta ish haqi yozuvi: `GET /payroll/{id}/`.
  static String payrollById(int id) => '/payroll/$id/';

  /// Ish haqi yozuv(lar)ini tasdiqlash: `POST /payroll/confirm/`.
  static const payrollConfirm = '/payroll/confirm/';

  // ── Expense requests (xarajat so'rovlari) ─────────────────────────────
  static const expenseRequests = '/expense-request/';

  /// Bitta so'rov: `GET /expense-request/{id}/`.
  static String expenseRequestById(int id) => '/expense-request/$id/';

  /// To'lovni qayd etish: `POST /expense-request/{id}/pay/` (bodysiz).
  static String expenseRequestPay(int id) => '/expense-request/$id/pay/';

  /// Rad etish: `POST /expense-request/{id}/cancel/` (`{cancel_reason}`,
  /// kamida 5 belgi — backend tekshiradi).
  static String expenseRequestCancel(int id) => '/expense-request/$id/cancel/';

  /// So'rovni tasdiqlash (yaratuvchi tomonidan, moliyachidan keyin):
  /// `POST /expense-request/{id}/confirm/` (bodysiz).
  static String expenseRequestConfirm(int id) =>
      '/expense-request/$id/confirm/';

  /// Xarajat cheklari — ro'yxat (`GET`, sahifalangan) + yaratish (multipart
  /// `POST {expense, file}`): `/expense-receipt/`.
  static const expenseReceipts = '/expense-receipt/';

  /// Bitta chek: `GET/DELETE /expense-receipt/{id}/`.
  static String expenseReceiptById(int id) => '/expense-receipt/$id/';

  // ── Projects ─────────────────────────────────────────────────────────────
  static const projects = '/projects/';

  /// Bitta loyiha to‘liq ma’lumoti — ishtirokchilar (Topshiruvchi tanlovi):
  /// `GET /projects/{id}/`.
  static String projectById(int id) => '/projects/$id/';

  static const projectsTrash = '/projects/trash/';

  static String projectHardDelete(int id) => '/projects/$id/hard_delete/';

  static String projectRestore(int id) => '/projects/$id/restore/';

  static const projectDocuments = '/project-documents/';

  static String projectDocumentById(int id) => '/project-documents/$id/';

  /// Vazifa faylini biriktirish (multipart `{task, file}`):
  /// `POST /task-attachments/`; ro‘yxat `GET ?task=`.
  static const taskAttachments = '/task-attachments/';

  /// Bitta biriktirilgan fayl: `DELETE /task-attachments/{id}/`.
  static String taskAttachmentById(int id) => '/task-attachments/$id/';

  /// Vazifa holatini o'zgartirish (`PATCH`, `{status, rejection_reason}`).
  static String taskChangeStatus(int id) => '/tasks/$id/change-status/';

  /// Rad etish skrinshoti (multipart `{task, file}`): `POST`.
  static const taskRejectionFiles = '/task-rejection-files/';

  // ── Meetings ──────────────────────────────────────────────────────────
  static const meetings = '/meetings/';

  /// Bitta yig‘ilish: `GET/PUT/PATCH/DELETE /meetings/{id}/`.
  static String meetingById(int id) => '/meetings/$id/';

  /// Yig‘ilishni yopish: `POST /meetings/{id}/close/`.
  static String meetingClose(int id) => '/meetings/$id/close/';

  static const meetingsTrash = '/meetings/trash/';

  static String meetingHardDelete(int id) => '/meetings/$id/hard_delete/';

  static String meetingRestore(int id) => '/meetings/$id/restore/';

  // ── Meeting attendance (qatnashuv) ────────────────────────────────────
  /// Ro‘yxat + filtr: `GET /meeting-attendance/?meeting=&user=&is_attended=`.
  static const meetingAttendance = '/meeting-attendance/';

  /// Bitta qatnashuv yozuvi: `GET/PATCH /meeting-attendance/{id}/`
  /// (qatnashmaslik sababi shu yerga `absence_reason` bilan PATCH qilinadi).
  static String meetingAttendanceById(int id) => '/meeting-attendance/$id/';
}
