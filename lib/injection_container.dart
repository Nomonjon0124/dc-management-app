import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'app/bloc/session_bloc.dart';
import 'config/routes/coordinator.dart';
import 'core/constants/storage_keys.dart';
import 'core/network/dio_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/network/interceptors/refresh_interceptor.dart';
import 'core/services/logger_service.dart';
import 'core/services/biometric_auth_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/pin/bloc/pin_bloc.dart';
import 'features/auth/presentation/role/bloc/role_select_bloc.dart';
import 'features/meetings/data/data_sources/meeting_remote_data_source.dart';
import 'features/meetings/data/data_sources/meeting_realtime_data_source.dart';
import 'features/meetings/data/repository/meeting_repository_impl.dart';
import 'features/meetings/data/repository/meeting_room_repository_impl.dart';
import 'features/meetings/data/services/livekit_media_service.dart';
import 'features/meetings/domain/repository/meeting_repository.dart';
import 'features/meetings/domain/repository/meeting_room_repository.dart';
import 'features/meetings/domain/usecases/close_meeting_usecase.dart';
import 'features/meetings/domain/usecases/create_meeting_usecase.dart';
import 'features/meetings/domain/usecases/delete_meeting_usecase.dart';
import 'features/meetings/domain/usecases/get_meeting_attendance_usecase.dart';
import 'features/meetings/domain/usecases/get_meeting_attendance_by_id_usecase.dart';
import 'features/meetings/domain/usecases/get_meeting_usecase.dart';
import 'features/meetings/domain/usecases/get_meetings_usecase.dart';
import 'features/meetings/domain/usecases/get_trashed_meetings_usecase.dart';
import 'features/meetings/domain/usecases/hard_delete_meeting_usecase.dart';
import 'features/meetings/domain/usecases/list_meeting_attendance_usecase.dart';
import 'features/meetings/domain/usecases/patch_meeting_usecase.dart';
import 'features/meetings/domain/usecases/restore_meeting_usecase.dart';
import 'features/meetings/domain/usecases/submit_absence_reason_usecase.dart';
import 'features/meetings/domain/usecases/update_meeting_attendance_usecase.dart';
import 'features/meetings/domain/usecases/update_meeting_usecase.dart';
import 'features/meetings/presentation/bloc/meeting_create_bloc.dart';
import 'features/meetings/presentation/bloc/meeting_filter_bloc.dart';
import 'features/meetings/presentation/bloc/meeting_reason_bloc.dart';
import 'features/meetings/presentation/bloc/meetings_bloc.dart';
import 'features/meetings/presentation/bloc/meeting_new_design/meeting_call_preview_bloc.dart';
import 'features/meetings/presentation/bloc/meeting_new_design/meeting_design_preview_bloc.dart';
import 'features/meetings/presentation/bloc/meeting_room_bloc.dart';
import 'features/meetings/presentation/services/meeting_sound_service.dart';
import 'features/tasks/data/data_sources/task_remote_data_source.dart';
import 'features/tasks/data/repository/task_repository_impl.dart';
import 'features/tasks/domain/repository/task_repository.dart';
import 'features/tasks/domain/usecases/change_task_status_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_project_members_usecase.dart';
import 'features/tasks/domain/usecases/get_task_edit_data_usecase.dart';
import 'features/tasks/domain/usecases/get_task_form_options_usecase.dart';
import 'features/tasks/domain/usecases/get_positions_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/get_managers_usecase.dart';
import 'features/tasks/domain/usecases/get_users_usecase.dart';
import 'features/tasks/domain/usecases/submit_task_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/bloc/task_create_bloc.dart';
import 'features/tasks/presentation/bloc/task_filter_bloc.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';
import 'features/daily_plans/data/data_sources/daily_plan_remote_data_source.dart';
import 'features/daily_plans/data/repository/daily_plan_repository_impl.dart';
import 'features/daily_plans/domain/repository/daily_plan_repository.dart';
import 'features/daily_plans/domain/usecases/daily_plan_usecases.dart';
import 'features/daily_plans/presentation/bloc/daily_plans_bloc.dart';
import 'features/notification/data/data_sources/notification_remote_data_source.dart';
import 'features/notification/data/data_sources/notification_socket_service.dart';
import 'features/notification/data/repository/notification_repository_impl.dart';
import 'features/notification/domain/repository/notification_repository.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/profile/data/data_sources/profile_remote_data_source.dart';
import 'features/reports/data/data_sources/reports_remote_data_source.dart';
import 'features/reports/data/repository/reports_repository_impl.dart';
import 'features/reports/domain/repository/reports_repository.dart';
import 'features/reports/domain/usecases/get_project_reports_usecase.dart';
import 'features/reports/domain/usecases/get_regions_usecase.dart';
import 'features/reports/domain/usecases/get_districts_usecase.dart';
import 'features/reports/domain/usecases/get_user_reports_usecase.dart';
import 'features/reports/domain/usecases/get_expense_reports_usecase.dart';
import 'features/reports/domain/usecases/get_expense_report_options_usecase.dart';
import 'features/reports/domain/usecases/get_payroll_reports_usecase.dart';
import 'features/reports/domain/usecases/get_task_reports_usecase.dart';
import 'features/reports/presentation/bloc/project_reports_bloc.dart';
import 'features/reports/presentation/bloc/project_reports_filter_bloc.dart';
import 'features/reports/presentation/bloc/reports_filter_bloc.dart';
import 'features/reports/presentation/bloc/user_reports_bloc.dart';
import 'features/reports/presentation/bloc/expense_reports_bloc.dart';
import 'features/reports/presentation/bloc/expense_reports_filter_bloc.dart';
import 'features/reports/presentation/bloc/task_reports_bloc.dart';
import 'features/reports/presentation/bloc/payroll_reports_bloc.dart';
import 'features/reports/presentation/bloc/task_reports_filter_bloc.dart';
import 'features/users/data/data_sources/users_remote_data_source.dart';
import 'features/users/data/repository/users_repository_impl.dart';
import 'features/users/domain/repository/users_repository.dart';
import 'features/users/domain/usecases/get_app_user_detail_usecase.dart';
import 'features/users/domain/usecases/get_app_users_usecase.dart';
import 'features/users/domain/usecases/create_app_user_usecase.dart';
import 'features/users/presentation/bloc/user_detail_bloc.dart';
import 'features/users/presentation/bloc/user_create_bloc.dart';
import 'features/users/presentation/bloc/users_bloc.dart';
import 'features/ledger/data/data_sources/ledger_remote_data_source.dart';
import 'features/ledger/data/repository/ledger_repository_impl.dart';
import 'features/ledger/domain/repository/ledger_repository.dart';
import 'features/ledger/domain/usecases/get_ledger_detail_usecase.dart';
import 'features/ledger/domain/usecases/get_ledger_usecase.dart';
import 'features/ledger/presentation/bloc/ledger_bloc.dart';
import 'features/ledger/presentation/bloc/ledger_detail_bloc.dart';
import 'features/expense_requests/data/data_sources/expense_requests_remote_data_source.dart';
import 'features/expense_requests/data/repository/expense_requests_repository_impl.dart';
import 'features/expense_requests/domain/repository/expense_requests_repository.dart';
import 'features/expense_requests/domain/usecases/cancel_expense_request_usecase.dart';
import 'features/expense_requests/domain/usecases/confirm_expense_request_usecase.dart';
import 'features/expense_requests/domain/usecases/create_expense_receipt_usecase.dart';
import 'features/expense_requests/domain/usecases/create_expense_request_usecase.dart';
import 'features/expense_requests/domain/usecases/get_expense_receipts_usecase.dart';
import 'features/expense_requests/domain/usecases/get_expense_request_detail_usecase.dart';
import 'features/expense_requests/domain/usecases/get_expense_requests_usecase.dart';
import 'features/expense_requests/domain/usecases/pay_expense_request_usecase.dart';
import 'features/expense_requests/presentation/bloc/expense_request_create_bloc.dart';
import 'features/expense_requests/presentation/bloc/expense_request_detail_bloc.dart';
import 'features/expense_requests/presentation/bloc/expense_request_options_bloc.dart';
import 'features/expense_requests/presentation/bloc/expense_requests_bloc.dart';
import 'features/payroll/data/data_sources/payroll_remote_data_source.dart';
import 'features/payroll/data/repository/payroll_repository_impl.dart';
import 'features/payroll/domain/repository/payroll_repository.dart';
import 'features/payroll/domain/usecases/confirm_payroll_usecase.dart';
import 'features/payroll/domain/usecases/get_payroll_detail_usecase.dart';
import 'features/payroll/domain/usecases/get_payrolls_usecase.dart';
import 'features/payroll/presentation/bloc/payroll_bloc.dart';
import 'features/payroll/presentation/bloc/payroll_detail_bloc.dart';
import 'features/users/presentation/bloc/users_filter_bloc.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/get_me_usecase.dart';
import 'features/profile/domain/usecases/update_me_usecase.dart';
import 'features/profile/presentation/bloc/change_password_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/projects/data/data_sources/project_remote_data_source.dart';
import 'features/projects/data/repository/project_repository_impl.dart';
import 'features/projects/domain/repository/project_repository.dart';
import 'features/projects/domain/usecases/project_usecases.dart';
import 'features/projects/presentation/bloc/project_create_bloc.dart';
import 'features/projects/presentation/bloc/project_details_bloc.dart';
import 'features/projects/presentation/bloc/project_filter_bloc.dart';
import 'features/projects/presentation/bloc/projects_bloc.dart';
import 'features/statistics/data/data_sources/statistics_remote_data_source.dart';
import 'features/statistics/data/repository/statistics_repository_impl.dart';
import 'features/statistics/domain/repository/statistics_repository.dart';
import 'features/statistics/domain/usecases/get_period_statistics_usecase.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core services ─────────────────────────────────────────────────────
  final storage = await StorageService.persistent(allowList: StorageKeys.all);
  getIt
    ..registerSingleton<StorageService>(storage)
    ..registerLazySingleton<LoggerService>(() => LoggerService())
    ..registerLazySingleton<BiometricAuthService>(() => BiometricAuthService())
    ..registerLazySingleton<TokenService>(() => TokenService(getIt()))
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(getIt(), getIt()),
    );

  // Session (drives navigation) — singleton so router + UI share one instance.
  getIt.registerLazySingleton<SessionBloc>(
    () => SessionBloc(tokenService: getIt(), storage: getIt()),
  );

  // ── Network ───────────────────────────────────────────────────────────
  // `Dio` alohida ro‘yxatga olinadi — Thunder debug overlay’i uni to‘g‘ridan
  // to‘g‘ri kuzatishi uchun (`getIt<Dio>()`).
  getIt.registerLazySingleton<Dio>(() {
    final dio = DioFactory.create();
    // Refresh + retry uchun alohida (interceptorsiz) Dio — sikldan saqlaydi.
    final refreshDio = DioFactory.create();
    dio.interceptors.addAll([
      AuthInterceptor(getIt<TokenService>()),
      RefreshInterceptor(
        tokenService: getIt<TokenService>(),
        refreshDio: refreshDio,
        session: () => getIt<SessionBloc>(),
      ),
      LoggingInterceptor(getIt<LoggerService>()),
    ]);
    return dio;
  });
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<Dio>()));

  // ── Auth feature ──────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        tokenService: getIt(),
        storage: getIt(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()))
    ..registerFactory<LoginBloc>(() => LoginBloc(loginUseCase: getIt()))
    ..registerFactory<PinBloc>(
      () => PinBloc(
        loginUseCase: getIt(),
        storage: getIt(),
        biometricAuth: getIt(),
      ),
    )
    // `UpdateMeUseCase` Profile bo‘limida ro‘yxatga olinadi — lazy factory
    // bo‘lgani uchun chaqiruv vaqtida (getIt<RoleSelectBloc>()) hal bo‘ladi.
    ..registerFactory<RoleSelectBloc>(() => RoleSelectBloc(updateMe: getIt()));

  // ── Profile feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetMeUseCase>(() => GetMeUseCase(getIt()))
    ..registerLazySingleton<UpdateMeUseCase>(() => UpdateMeUseCase(getIt()))
    ..registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt()),
    )
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(getMe: getIt(), updateMe: getIt()),
    )
    ..registerFactory<ChangePasswordBloc>(
      () => ChangePasswordBloc(changePassword: getIt(), storage: getIt()),
    );

  // ── Meetings feature ──────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<MeetingRemoteDataSource>(
      () => MeetingRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<MeetingRepository>(
      () => MeetingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetMeetingsUseCase>(
      () => GetMeetingsUseCase(getIt()),
    )
    ..registerLazySingleton<CreateMeetingUseCase>(
      () => CreateMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<GetMeetingUseCase>(() => GetMeetingUseCase(getIt()))
    ..registerLazySingleton<UpdateMeetingUseCase>(
      () => UpdateMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<PatchMeetingUseCase>(
      () => PatchMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<DeleteMeetingUseCase>(
      () => DeleteMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<CloseMeetingUseCase>(
      () => CloseMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<GetTrashedMeetingsUseCase>(
      () => GetTrashedMeetingsUseCase(getIt()),
    )
    ..registerLazySingleton<HardDeleteMeetingUseCase>(
      () => HardDeleteMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<RestoreMeetingUseCase>(
      () => RestoreMeetingUseCase(getIt()),
    )
    ..registerLazySingleton<GetMeetingAttendanceUseCase>(
      () => GetMeetingAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<ListMeetingAttendanceUseCase>(
      () => ListMeetingAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<GetMeetingAttendanceByIdUseCase>(
      () => GetMeetingAttendanceByIdUseCase(getIt()),
    )
    ..registerLazySingleton<UpdateMeetingAttendanceUseCase>(
      () => UpdateMeetingAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<SubmitAbsenceReasonUseCase>(
      () => SubmitAbsenceReasonUseCase(getIt()),
    )
    ..registerFactory<MeetingFilterBloc>(
      () => MeetingFilterBloc(getOptions: getIt(), getUsers: getIt()),
    )
    ..registerFactory<MeetingCreateBloc>(
      () => MeetingCreateBloc(
        updateMeeting: getIt(),
        getOptions: getIt(),
        getMembers: getIt(),
        getMeeting: getIt(),
        createMeeting: getIt(),
        closeMeeting: getIt(),
        getAttendance: getIt(),
        updateAttendance: getIt(),
      ),
    )
    ..registerFactory<MeetingsBloc>(
      () => MeetingsBloc(getMeetings: getIt(), deleteMeeting: getIt()),
    )
    ..registerFactory<MeetingReasonBloc>(
      () => MeetingReasonBloc(
        getMeeting: getIt(),
        getAttendance: getIt(),
        submitReason: getIt(),
        updateAttendance: getIt(),
        storage: getIt(),
      ),
    )
    ..registerFactory<MeetingCallPreviewBloc>(MeetingCallPreviewBloc.new)
    ..registerFactory<MeetingDesignPreviewBloc>(MeetingDesignPreviewBloc.new)
    ..registerLazySingleton<MeetingRealtimeDataSource>(
      () => MeetingRealtimeDataSourceImpl(client: getIt(), logger: getIt()),
    )
    ..registerLazySingleton<LiveKitMediaService>(LiveKitMediaService.new)
    ..registerFactory<MeetingSoundService>(MeetingSoundServiceImpl.new)
    ..registerLazySingleton<MeetingRoomRepository>(
      () => MeetingRoomRepositoryImpl(
        realtime: getIt(),
        media: getIt(),
        storage: getIt(),
      ),
    )
    ..registerFactory<MeetingRoomBloc>(
      () => MeetingRoomBloc(
        repository: getIt(),
        closeMeeting: getIt(),
        getMeeting: getIt(),
        soundService: getIt(),
      ),
    );

  // ── Tasks feature ─────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(getIt()))
    ..registerLazySingleton<GetTasksUseCase>(() => GetTasksUseCase(getIt()))
    ..registerLazySingleton<GetTaskFormOptionsUseCase>(
      () => GetTaskFormOptionsUseCase(getIt()),
    )
    ..registerLazySingleton<GetPositionsUseCase>(
      () => GetPositionsUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectMembersUseCase>(
      () => GetProjectMembersUseCase(getIt()),
    )
    ..registerLazySingleton<GetUsersUseCase>(() => GetUsersUseCase(getIt()))
    ..registerLazySingleton<GetManagersUseCase>(
      () => GetManagersUseCase(getIt()),
    )
    ..registerLazySingleton<SubmitTaskUseCase>(() => SubmitTaskUseCase(getIt()))
    ..registerLazySingleton<UpdateTaskUseCase>(() => UpdateTaskUseCase(getIt()))
    ..registerLazySingleton<GetTaskEditDataUseCase>(
      () => GetTaskEditDataUseCase(getIt()),
    )
    ..registerLazySingleton<ChangeTaskStatusUseCase>(
      () => ChangeTaskStatusUseCase(getIt()),
    )
    ..registerLazySingleton<DeleteTaskUseCase>(() => DeleteTaskUseCase(getIt()))
    ..registerFactory<TasksBloc>(
      () => TasksBloc(getTasks: getIt(), deleteTask: getIt()),
    )
    ..registerFactory<TaskCreateBloc>(
      () => TaskCreateBloc(
        getOptions: getIt(),
        getMembers: getIt(),
        submitTask: getIt(),
        getEditData: getIt(),
        updateTask: getIt(),
        changeStatus: getIt(),
        getMe: getIt(),
        getProject: getIt(),
      ),
    )
    ..registerFactory<TaskFilterBloc>(
      () => TaskFilterBloc(getOptions: getIt(), getUsers: getIt()),
    );

  getIt
    ..registerLazySingleton<DailyPlanRemoteDataSource>(
      () => DailyPlanRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<DailyPlanRepository>(
      () => DailyPlanRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetDailyPlansUseCase>(
      () => GetDailyPlansUseCase(getIt()),
    )
    ..registerLazySingleton<CreateDailyPlanUseCase>(
      () => CreateDailyPlanUseCase(getIt()),
    )
    ..registerLazySingleton<UpdateDailyPlanUseCase>(
      () => UpdateDailyPlanUseCase(getIt()),
    )
    ..registerLazySingleton<DeleteDailyPlanUseCase>(
      () => DeleteDailyPlanUseCase(getIt()),
    )
    ..registerLazySingleton<CreateDailyPlanItemUseCase>(
      () => CreateDailyPlanItemUseCase(getIt()),
    )
    ..registerLazySingleton<UpdateDailyPlanItemUseCase>(
      () => UpdateDailyPlanItemUseCase(getIt()),
    )
    ..registerFactory<DailyPlansBloc>(
      () => DailyPlansBloc(
        getPlans: getIt(),
        createPlan: getIt(),
        updatePlan: getIt(),
        deletePlan: getIt(),
        createItem: getIt(),
        updateItem: getIt(),
      ),
    );

  getIt
    ..registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProjectRepository>(
      () => ProjectRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetProjectsUseCase>(
      () => GetProjectsUseCase(getIt()),
    )
    ..registerLazySingleton<CreateProjectUseCase>(
      () => CreateProjectUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectUseCase>(() => GetProjectUseCase(getIt()))
    ..registerLazySingleton<UpdateProjectUseCase>(
      () => UpdateProjectUseCase(getIt()),
    )
    ..registerLazySingleton<PatchProjectUseCase>(
      () => PatchProjectUseCase(getIt()),
    )
    ..registerLazySingleton<DeleteProjectUseCase>(
      () => DeleteProjectUseCase(getIt()),
    )
    ..registerLazySingleton<GetTrashedProjectsUseCase>(
      () => GetTrashedProjectsUseCase(getIt()),
    )
    ..registerLazySingleton<HardDeleteProjectUseCase>(
      () => HardDeleteProjectUseCase(getIt()),
    )
    ..registerLazySingleton<RestoreProjectUseCase>(
      () => RestoreProjectUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectDocumentsUseCase>(
      () => GetProjectDocumentsUseCase(getIt()),
    )
    ..registerLazySingleton<CreateProjectDocumentUseCase>(
      () => CreateProjectDocumentUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectDocumentUseCase>(
      () => GetProjectDocumentUseCase(getIt()),
    )
    ..registerLazySingleton<UpdateProjectDocumentUseCase>(
      () => UpdateProjectDocumentUseCase(getIt()),
    )
    ..registerLazySingleton<PatchProjectDocumentUseCase>(
      () => PatchProjectDocumentUseCase(getIt()),
    )
    ..registerLazySingleton<DeleteProjectDocumentUseCase>(
      () => DeleteProjectDocumentUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectShortsUseCase>(
      () => GetProjectShortsUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectShortUseCase>(
      () => GetProjectShortUseCase(getIt()),
    )
    ..registerFactory<ProjectFilterBloc>(
      () => ProjectFilterBloc(getUsers: getIt()),
    )
    ..registerFactory<ProjectCreateBloc>(
      () => ProjectCreateBloc(
        getUsers: getIt(),
        getManagers: getIt(),
        createProject: getIt(),
        updateProject: getIt(),
        createDocument: getIt(),
        getDocuments: getIt(),
        deleteDocument: getIt(),
      ),
    )
    ..registerFactory<ProjectDetailsBloc>(
      () => ProjectDetailsBloc(getProject: getIt()),
    )
    ..registerFactory<ProjectsBloc>(
      () => ProjectsBloc(getProjects: getIt(), deleteProject: getIt()),
    );

  // ── Reports feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetUserReportsUseCase>(
      () => GetUserReportsUseCase(getIt()),
    )
    ..registerLazySingleton<GetRegionsUseCase>(() => GetRegionsUseCase(getIt()))
    ..registerLazySingleton<GetDistrictsUseCase>(
      () => GetDistrictsUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectReportsUseCase>(
      () => GetProjectReportsUseCase(getIt()),
    )
    ..registerLazySingleton<GetExpenseReportsUseCase>(
      () => GetExpenseReportsUseCase(getIt()),
    )
    ..registerLazySingleton<GetExpenseReportOptionsUseCase>(
      () => GetExpenseReportOptionsUseCase(getIt()),
    )
    ..registerLazySingleton<GetTaskReportsUseCase>(
      () => GetTaskReportsUseCase(getIt()),
    )
    ..registerLazySingleton<GetPayrollReportsUseCase>(
      () => GetPayrollReportsUseCase(getIt()),
    )
    ..registerFactory<UserReportsBloc>(
      () => UserReportsBloc(getUserReports: getIt()),
    )
    ..registerFactory<ReportsFilterBloc>(
      () => ReportsFilterBloc(
        getOptions: getIt(),
        getUsers: getIt(),
        getRegions: getIt(),
      ),
    )
    ..registerFactory<ProjectReportsBloc>(
      () => ProjectReportsBloc(getProjectReports: getIt()),
    )
    ..registerFactory<ProjectReportsFilterBloc>(
      () => ProjectReportsFilterBloc(getUsers: getIt()),
    )
    ..registerFactory<ExpenseReportsBloc>(
      () => ExpenseReportsBloc(getExpenseReports: getIt()),
    )
    ..registerFactory<ExpenseReportsFilterBloc>(
      () => ExpenseReportsFilterBloc(getOptions: getIt(), getUsers: getIt()),
    )
    ..registerFactory<TaskReportsBloc>(
      () => TaskReportsBloc(getTaskReports: getIt()),
    )
    ..registerFactory<TaskReportsFilterBloc>(
      () => TaskReportsFilterBloc(getOptions: getIt(), getUsers: getIt()),
    )
    ..registerFactory<PayrollReportsBloc>(
      () => PayrollReportsBloc(getPayrollReports: getIt()),
    );

  // ── Users feature ─────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(getIt()))
    ..registerLazySingleton<GetAppUsersUseCase>(
      () => GetAppUsersUseCase(getIt()),
    )
    ..registerLazySingleton<GetAppUserDetailUseCase>(
      () => GetAppUserDetailUseCase(getIt()),
    )
    ..registerLazySingleton<CreateAppUserUseCase>(
      () => CreateAppUserUseCase(getIt()),
    )
    ..registerFactory<UsersBloc>(() => UsersBloc(getUsers: getIt()))
    ..registerFactory<UserDetailBloc>(() => UserDetailBloc(getUser: getIt()))
    ..registerFactory<UserCreateBloc>(
      () => UserCreateBloc(
        getPositions: getIt(),
        getRegions: getIt(),
        getDistricts: getIt(),
        createUser: getIt(),
      ),
    )
    ..registerFactory<UsersFilterBloc>(
      () => UsersFilterBloc(getOptions: getIt()),
    );

  // ── Ledger (moliya tarixi) feature ────────────────────────────────────
  getIt
    ..registerLazySingleton<LedgerRemoteDataSource>(
      () => LedgerRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<LedgerRepository>(
      () => LedgerRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetLedgerUseCase>(() => GetLedgerUseCase(getIt()))
    ..registerLazySingleton<GetLedgerDetailUseCase>(
      () => GetLedgerDetailUseCase(getIt()),
    )
    ..registerFactory<LedgerBloc>(() => LedgerBloc(getLedger: getIt()))
    ..registerFactory<LedgerDetailBloc>(
      () => LedgerDetailBloc(getEntry: getIt()),
    );

  // ── Payroll (ish haqi) feature ────────────────────────────────────────
  getIt
    ..registerLazySingleton<PayrollRemoteDataSource>(
      () => PayrollRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<PayrollRepository>(
      () => PayrollRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetPayrollsUseCase>(
      () => GetPayrollsUseCase(getIt()),
    )
    ..registerLazySingleton<GetPayrollDetailUseCase>(
      () => GetPayrollDetailUseCase(getIt()),
    )
    ..registerLazySingleton<ConfirmPayrollUseCase>(
      () => ConfirmPayrollUseCase(getIt()),
    )
    ..registerFactory<PayrollBloc>(() => PayrollBloc(getPayrolls: getIt()))
    ..registerFactory<PayrollDetailBloc>(
      () => PayrollDetailBloc(getPayroll: getIt(), confirmPayroll: getIt()),
    );

  // ── Expense requests (xarajat so'rovlari) feature ─────────────────────
  getIt
    ..registerLazySingleton<ExpenseRequestsRemoteDataSource>(
      () => ExpenseRequestsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ExpenseRequestsRepository>(
      () => ExpenseRequestsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetExpenseRequestsUseCase>(
      () => GetExpenseRequestsUseCase(getIt()),
    )
    ..registerLazySingleton<CreateExpenseRequestUseCase>(
      () => CreateExpenseRequestUseCase(getIt()),
    )
    ..registerLazySingleton<GetExpenseRequestDetailUseCase>(
      () => GetExpenseRequestDetailUseCase(getIt()),
    )
    ..registerLazySingleton<PayExpenseRequestUseCase>(
      () => PayExpenseRequestUseCase(getIt()),
    )
    ..registerLazySingleton<CancelExpenseRequestUseCase>(
      () => CancelExpenseRequestUseCase(getIt()),
    )
    ..registerLazySingleton<ConfirmExpenseRequestUseCase>(
      () => ConfirmExpenseRequestUseCase(getIt()),
    )
    ..registerLazySingleton<GetExpenseReceiptsUseCase>(
      () => GetExpenseReceiptsUseCase(getIt()),
    )
    ..registerLazySingleton<CreateExpenseReceiptUseCase>(
      () => CreateExpenseReceiptUseCase(getIt()),
    )
    ..registerFactory<ExpenseRequestsBloc>(
      () => ExpenseRequestsBloc(getExpenseRequests: getIt()),
    )
    ..registerFactory<ExpenseRequestCreateBloc>(
      () => ExpenseRequestCreateBloc(create: getIt()),
    )
    ..registerFactory<ExpenseRequestOptionsBloc>(
      () => ExpenseRequestOptionsBloc(getOptions: getIt()),
    )
    ..registerFactory<ExpenseRequestDetailBloc>(
      () => ExpenseRequestDetailBloc(
        getRequest: getIt(),
        payRequest: getIt(),
        cancelRequest: getIt(),
        confirmRequest: getIt(),
        getReceipts: getIt(),
        createReceipt: getIt(),
      ),
    );

  // ── Statistics feature ────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<StatisticsRemoteDataSource>(
      () => StatisticsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetPeriodStatisticsUseCase>(
      () => GetPeriodStatisticsUseCase(getIt()),
    )
    ..registerFactory<StatisticsBloc>(() => StatisticsBloc(getPeriod: getIt()));

  // ── Notification feature ──────────────────────────────────────────────
  getIt
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(getIt()),
    )
    // WebSocket real-vaqt oqimi — datasource orqali ticket oladi (repo’ga
    // bog‘liq emas, sikldan xoli). Singleton — app bo‘yicha yagona ulanish.
    ..registerLazySingleton<NotificationSocketService>(
      () => NotificationSocketService(remote: getIt(), logger: getIt()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<WatchNotificationsUseCase>(
      () => WatchNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(getIt()),
    )
    ..registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(getIt()),
    )
    ..registerLazySingleton<ReadAllNotificationsUseCase>(
      () => ReadAllNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<RegisterDeviceUseCase>(
      () => RegisterDeviceUseCase(getIt()),
    )
    ..registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotifications: getIt(),
        getUnreadCount: getIt(),
        markRead: getIt(),
        readAll: getIt(),
        watch: getIt(),
      ),
    );

  // ── Router — built once from the session cubit. ─────────────────────────
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<SessionBloc>()));
}
