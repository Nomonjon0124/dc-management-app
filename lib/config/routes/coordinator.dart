import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/bloc/session_bloc.dart';
import '../../core/access/nav_permissions.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pin/pages/pin_page.dart';
import '../../features/auth/presentation/role/pages/role_select_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/meetings/domain/entities/meeting.dart';
import '../../features/meetings/domain/entities/meeting_filter.dart';
import '../../features/meetings/presentation/pages/meeting_create_page.dart';
import '../../features/meetings/presentation/pages/meeting_filter_page.dart';
import '../../features/meetings/presentation/pages/meeting_reason_page.dart';
import '../../features/meetings/presentation/pages/meeting_new_design/meeting_design_preview_page.dart';
import '../../features/meetings/presentation/pages/meeting_new_design/meeting_call_preview_page.dart';
import '../../features/meetings/presentation/pages/meeting_room_page.dart';
import '../../features/meetings/presentation/pages/meetings_page.dart';
import '../../features/reports/domain/entities/project_report_filter.dart';
import '../../features/reports/domain/entities/expense_report_filter.dart';
import '../../features/reports/domain/entities/user_report_filter.dart';
import '../../features/reports/presentation/pages/project_reports_filter_page.dart';
import '../../features/reports/presentation/pages/project_reports_page.dart';
import '../../features/reports/presentation/pages/expense_reports_filter_page.dart';
import '../../features/reports/presentation/pages/expense_reports_page.dart';
import '../../features/reports/domain/entities/task_report_filter.dart';
import '../../features/reports/presentation/pages/task_reports_filter_page.dart';
import '../../features/reports/domain/entities/payroll_report_filter.dart';
import '../../features/reports/presentation/pages/payroll_reports_filter_page.dart';
import '../../features/reports/presentation/pages/payroll_reports_page.dart';
import '../../features/reports/presentation/pages/task_reports_page.dart';
import '../../features/reports/presentation/pages/user_reports_filter_page.dart';
import '../../features/reports/presentation/pages/user_reports_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/projects/domain/entities/project_filter.dart';
import '../../features/projects/presentation/pages/add_project_page.dart';
import '../../features/projects/presentation/pages/edit_project_page.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/projects/presentation/pages/project_filter_page.dart';
import '../../features/projects/presentation/pages/projects_list_page.dart';
import '../../features/tasks/domain/entities/task_filter.dart';
import '../../features/tasks/presentation/pages/task_create_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/task_filter_page.dart';
import '../../features/tasks/presentation/pages/task_multi_select_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/daily_plans/domain/entities/daily_plan.dart';
import '../../features/daily_plans/presentation/pages/daily_plan_editor_page.dart';
import '../../features/daily_plans/presentation/pages/daily_plans_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/users/domain/entities/users_filter.dart';
import '../../features/users/presentation/pages/user_detail_page.dart';
import '../../features/users/presentation/pages/user_create_page.dart';
import '../../features/users/presentation/pages/users_filter_page.dart';
import '../../features/ledger/domain/entities/ledger_filter.dart';
import '../../features/ledger/presentation/pages/ledger_detail_page.dart';
import '../../features/ledger/presentation/pages/ledger_filter_page.dart';
import '../../features/ledger/presentation/pages/ledger_list_page.dart';
import '../../features/expense_requests/domain/entities/expense_request_filter.dart';
import '../../features/expense_requests/presentation/pages/expense_request_create_page.dart';
import '../../features/expense_requests/presentation/pages/expense_requests_filter_page.dart';
import '../../features/expense_requests/presentation/pages/expense_requests_list_page.dart';
import '../../features/expense_requests/presentation/pages/query_data_page.dart';
import '../../features/payroll/domain/entities/payroll_filter.dart';
import '../../features/payroll/presentation/pages/payroll_detail_page.dart';
import '../../features/payroll/presentation/pages/payroll_filter_page.dart';
import '../../features/payroll/presentation/pages/payroll_list_page.dart';
import 'entity/routes.dart';

/// Root navigator key — exposed for context-free navigation (snackbars,
/// dialogs, theme toggles) outside the widget tree.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized application router.
///
/// All routing lives here. A single [redirect] guard reads [SessionBloc] state
/// and decides the destination; [GoRouterRefreshStream] re-runs that guard on
/// every session change, so login / logout / timeout / attendance transitions
/// reroute automatically with no imperative navigation calls scattered around.
class AppRouter {
  AppRouter(this._session) {
    router = _build();
  }

  final SessionBloc _session;
  late final GoRouter router;

  GoRouter _build() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: Routes.splash.path,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(_session.stream),
      redirect: _guard,
      routes: <RouteBase>[
        GoRoute(
          name: Routes.splash.name,
          path: Routes.splash.path,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          name: Routes.login.name,
          path: Routes.login.path,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: Routes.pinCode.name,
          path: Routes.pinCode.path,
          builder: (context, state) => const PinPage(),
        ),
        GoRoute(
          name: Routes.roleSelect.name,
          path: Routes.roleSelect.path,
          builder: (context, state) => const RoleSelectPage(),
        ),
        GoRoute(
          name: Routes.checkCode.name,
          path: Routes.checkCode.path,
          builder: (context, state) => const AttendancePage(),
        ),
        GoRoute(
          name: Routes.home.name,
          path: Routes.home.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: Routes.notifications.name,
          path: Routes.notifications.path,
          builder: (context, state) => const NotificationPage(),
        ),
        GoRoute(
          name: Routes.profile.name,
          path: Routes.profile.path,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          name: Routes.profileEdit.name,
          path: Routes.profileEdit.path,
          builder: (context, state) => const ProfileEditPage(),
        ),
        GoRoute(
          name: Routes.security.name,
          path: Routes.security.path,
          builder: (context, state) => const SecurityPage(),
        ),
        GoRoute(
          name: Routes.tasks.name,
          path: Routes.tasks.path,
          builder: (context, state) => const TasksPage(),
        ),
        GoRoute(
          name: Routes.dailyPlans.name,
          path: Routes.dailyPlans.path,
          builder: (context, state) => const DailyPlansPage(),
        ),
        GoRoute(
          name: Routes.dailyPlanCreate.name,
          path: Routes.dailyPlanCreate.path,
          builder: (context, state) => const DailyPlanEditorPage(),
        ),
        GoRoute(
          name: Routes.dailyPlanEdit.name,
          path: Routes.dailyPlanEdit.path,
          builder: (context, state) => DailyPlanEditorPage(
            initial: state.extra is DailyPlan
                ? state.extra! as DailyPlan
                : null,
          ),
        ),
        GoRoute(
          name: Routes.projectsList.name,
          path: Routes.projectsList.path,
          builder: (context, state) => const ProjectsListPage(),
        ),
        GoRoute(
          name: Routes.projectCreate.name,
          path: Routes.projectCreate.path,
          builder: (context, state) => const AddProjectPage(),
        ),
        GoRoute(
          name: Routes.projectDetails.name,
          path: Routes.projectDetails.path,
          builder: (context, state) => ProjectDetailsPage(
            projectId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.projectEdit.name,
          path: Routes.projectEdit.path,
          builder: (context, state) => EditProjectPage(
            projectId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.projectFilter.name,
          path: Routes.projectFilter.path,
          builder: (context, state) => ProjectFilterPage(
            initial: state.extra is ProjectFilter
                ? state.extra! as ProjectFilter
                : ProjectFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.taskCreate.name,
          path: Routes.taskCreate.path,
          builder: (context, state) => const TaskCreatePage(),
        ),
        GoRoute(
          name: Routes.taskEdit.name,
          path: Routes.taskEdit.path,
          builder: (context, state) => TaskCreatePage(
            taskId: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          name: Routes.taskFilter.name,
          path: Routes.taskFilter.path,
          builder: (context, state) => TaskFilterPage(
            initial: state.extra is TaskFilter
                ? state.extra! as TaskFilter
                : TaskFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.taskMultiSelect.name,
          path: Routes.taskMultiSelect.path,
          builder: (context, state) =>
              TaskMultiSelectPage(args: state.extra! as TaskMultiSelectArgs),
        ),
        // `/tasks/:id` — literal yo'llardan (create/filter) keyin turishi
        // shart, aks holda ularni ham ushlab qoladi.
        GoRoute(
          name: Routes.taskDetail.name,
          path: Routes.taskDetail.path,
          builder: (context, state) => TaskDetailPage(
            taskId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.meetings.name,
          path: Routes.meetings.path,
          builder: (context, state) => const MeetingsPage(),
        ),
        GoRoute(
          name: Routes.usersFilter.name,
          path: Routes.usersFilter.path,
          builder: (context, state) => UsersFilterPage(
            initial: state.extra is UsersFilter
                ? state.extra! as UsersFilter
                : UsersFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.userCreate.name,
          path: Routes.userCreate.path,
          builder: (context, state) => const UserCreatePage(),
        ),
        GoRoute(
          name: Routes.userDetail.name,
          path: Routes.userDetail.path,
          builder: (context, state) => UserDetailPage(
            userId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.ledgerList.name,
          path: Routes.ledgerList.path,
          builder: (context, state) => const LedgerListPage(),
        ),
        GoRoute(
          name: Routes.ledgerFilter.name,
          path: Routes.ledgerFilter.path,
          builder: (context, state) => LedgerFilterPage(
            initial: state.extra is LedgerFilter
                ? state.extra! as LedgerFilter
                : LedgerFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.ledgerDetail.name,
          path: Routes.ledgerDetail.path,
          builder: (context, state) => LedgerDetailPage(
            entryId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.payrollList.name,
          path: Routes.payrollList.path,
          builder: (context, state) => const PayrollListPage(),
        ),
        GoRoute(
          name: Routes.payrollFilter.name,
          path: Routes.payrollFilter.path,
          builder: (context, state) => PayrollFilterPage(
            initial: state.extra is PayrollFilter
                ? state.extra! as PayrollFilter
                : PayrollFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.payrollDetail.name,
          path: Routes.payrollDetail.path,
          builder: (context, state) => PayrollDetailPage(
            payrollId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.expenseRequests.name,
          path: Routes.expenseRequests.path,
          builder: (context, state) => const ExpenseRequestsListPage(),
        ),
        GoRoute(
          name: Routes.expenseRequestsFilter.name,
          path: Routes.expenseRequestsFilter.path,
          builder: (context, state) => ExpenseRequestsFilterPage(
            initial: state.extra is ExpenseRequestFilter
                ? state.extra! as ExpenseRequestFilter
                : ExpenseRequestFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.expenseRequestCreate.name,
          path: Routes.expenseRequestCreate.path,
          builder: (context, state) => const ExpenseRequestCreatePage(),
        ),
        GoRoute(
          name: Routes.expenseRequestDetail.name,
          path: Routes.expenseRequestDetail.path,
          builder: (context, state) => QueryDataPage(
            requestId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
          ),
        ),
        GoRoute(
          name: Routes.userReports.name,
          path: Routes.userReports.path,
          builder: (context, state) => const UserReportsPage(),
        ),
        GoRoute(
          name: Routes.userReportsFilter.name,
          path: Routes.userReportsFilter.path,
          builder: (context, state) => UserReportsFilterPage(
            initial: state.extra is UserReportFilter
                ? state.extra! as UserReportFilter
                : UserReportFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.projectReports.name,
          path: Routes.projectReports.path,
          builder: (context, state) => const ProjectReportsPage(),
        ),
        GoRoute(
          name: Routes.projectReportsFilter.name,
          path: Routes.projectReportsFilter.path,
          builder: (context, state) => ProjectReportsFilterPage(
            initial: state.extra is ProjectReportFilter
                ? state.extra! as ProjectReportFilter
                : ProjectReportFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.expenseReports.name,
          path: Routes.expenseReports.path,
          builder: (context, state) => const ExpenseReportsPage(),
        ),
        GoRoute(
          name: Routes.expenseReportsFilter.name,
          path: Routes.expenseReportsFilter.path,
          builder: (context, state) => ExpenseReportsFilterPage(
            initial: state.extra is ExpenseReportFilter
                ? state.extra! as ExpenseReportFilter
                : ExpenseReportFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.taskReports.name,
          path: Routes.taskReports.path,
          builder: (context, state) => const TaskReportsPage(),
        ),
        GoRoute(
          name: Routes.taskReportsFilter.name,
          path: Routes.taskReportsFilter.path,
          builder: (context, state) => TaskReportsFilterPage(
            initial: state.extra is TaskReportFilter
                ? state.extra! as TaskReportFilter
                : TaskReportFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.payrollReports.name,
          path: Routes.payrollReports.path,
          builder: (context, state) => const PayrollReportsPage(),
        ),
        GoRoute(
          name: Routes.payrollReportsFilter.name,
          path: Routes.payrollReportsFilter.path,
          builder: (context, state) => PayrollReportsFilterPage(
            initial: state.extra is PayrollReportFilter
                ? state.extra! as PayrollReportFilter
                : PayrollReportFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.meetingCreate.name,
          path: Routes.meetingCreate.path,
          builder: (context, state) => const MeetingCreatePage(newDesign: true),
        ),
        GoRoute(
          name: Routes.meetingEdit.name,
          path: Routes.meetingEdit.path,
          builder: (context, state) => MeetingCreatePage(
            initial: state.extra is Meeting ? state.extra! as Meeting : null,
            newDesign: true,
          ),
        ),
        GoRoute(
          name: Routes.meetingFilter.name,
          path: Routes.meetingFilter.path,
          builder: (context, state) => MeetingFilterPage(
            initial: state.extra is MeetingFilter
                ? state.extra! as MeetingFilter
                : MeetingFilter.empty,
          ),
        ),
        GoRoute(
          name: Routes.meetingUiPreview.name,
          path: Routes.meetingUiPreview.path,
          builder: (context, state) => MeetingDesignPreviewPage(
            mode: switch (state.uri.queryParameters['mode']) {
              'detail' || 'details' => MeetingPreviewMode.details,
              _ => MeetingPreviewMode.create,
            },
          ),
        ),
        GoRoute(
          name: Routes.meetingCallPreview.name,
          path: Routes.meetingCallPreview.path,
          builder: (context, state) => const MeetingCallPreviewPage(),
        ),
        GoRoute(
          name: Routes.meetingRoom.name,
          path: Routes.meetingRoom.path,
          builder: (context, state) => MeetingRoomPage(
            meetingId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            initialMeeting: state.extra is Meeting
                ? state.extra! as Meeting
                : null,
          ),
        ),
        GoRoute(
          name: Routes.meetingDetail.name,
          path: Routes.meetingDetail.path,
          builder: (context, state) => MeetingCreatePage(
            initial: state.extra is Meeting ? state.extra! as Meeting : null,
            meetingId: int.tryParse(state.pathParameters['id'] ?? ''),
            readOnly: true,
            newDesign: true,
          ),
        ),
        GoRoute(
          name: Routes.meetingReason.name,
          path: Routes.meetingReason.path,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return MeetingReasonPage(meetingId: id);
          },
        ),
      ],
    );
  }

  /// The single redirect guard. Pure function of session state + target path.
  ///
  /// Flow: splash → login (no cached user) → pin (cached user, re-auth) →
  /// roleSelect (multiple roles, none chosen) → home.
  String? _guard(BuildContext context, GoRouterState state) {
    final session = _session.state;
    final location = state.matchedLocation;

    final onSplash = location == Routes.splash.path;
    final onLogin = location == Routes.login.path;
    final onPin = location == Routes.pinCode.path;
    final onRoleSelect = location == Routes.roleSelect.path;

    // Still resolving stored session -> hold on splash.
    if (!session.isResolved) {
      return onSplash ? null : Routes.splash.path;
    }

    // No cached login -> full login screen.
    if (session.isUnauthenticated) {
      return onLogin ? null : Routes.login.path;
    }

    // Cached login, needs PIN re-auth -> PIN screen. Purely state-driven:
    // `_onResumed` emits `pinRequired` on a real background→resume timeout, and
    // the resume nudge (`router.refresh()`) re-runs this guard once that state
    // has settled. No free-running time predicate here — that would falsely
    // lock during long foreground use (lastActiveAt isn't bumped in foreground).
    if (session.isPinRequired) {
      return onPin ? null : Routes.pinCode.path;
    }

    // Authenticated with multiple roles, none chosen -> role selection.
    if (session.roleSelectionRequired) {
      return onRoleSelect ? null : Routes.roleSelect.path;
    }

    if (location == Routes.projectCreate.path &&
        !NavPermissions.canCreateProject(session.roleType)) {
      return Routes.projectsList.path;
    }

    if (location.startsWith('/projects/') &&
        location.endsWith('/edit') &&
        !NavPermissions.canManageProject(session.roleType)) {
      final id = state.pathParameters['id'];
      return id == null
          ? Routes.projectsList.path
          : Routes.projectDetails.path.replaceFirst(':id', id);
    }

    // Fully authenticated: keep away from gates.
    if (onSplash || onLogin || onPin || onRoleSelect) {
      return Routes.home.path;
    }

    return null;
  }
}

/// Adapts a [Stream] (a bloc/cubit stream) into a [Listenable] that GoRouter's
/// `refreshListenable` understands. Notifies once on creation, then on each event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
