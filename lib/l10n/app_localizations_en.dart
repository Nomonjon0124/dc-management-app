// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pinTitle => 'Enter PIN code';

  @override
  String get pinSubtitle => 'Enter your PIN code to confirm sign-in';

  @override
  String get pinIncorrect => 'Incorrect PIN code';

  @override
  String get pinRetry => 'Please try again';

  @override
  String get pinBlocked => 'Access temporarily blocked';

  @override
  String pinBlockedRetryIn(String time) {
    return 'Try again in: $time';
  }

  @override
  String get biometricUnlock => 'Use biometrics';

  @override
  String get biometricPromptReason => 'Confirm access to your account';

  @override
  String get biometricNotAvailable => 'Biometric sign-in is not available';

  @override
  String get biometricNotEnrolled => 'No biometrics are set up on this device';

  @override
  String get biometricLocked => 'Biometric sign-in is temporarily locked';

  @override
  String get biometricTryPin => 'Continue with PIN';

  @override
  String get sessionExpiredLoginAgain =>
      'Session expired. Please sign in again';

  @override
  String get roleTitle => 'You can use the app with multiple roles';

  @override
  String get roleSubtitle => 'Select one of the following.';

  @override
  String get roleAdministrator => 'Administrator';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get notificationClose => 'Close';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOpenFile => 'Open file';

  @override
  String get commonDownloadFile => 'Download file';

  @override
  String get navHome => 'Home';

  @override
  String get navUsers => 'Users';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navFinance => 'Finance';

  @override
  String get navReports => 'Reports';

  @override
  String get reportEmployee => 'By employee';

  @override
  String get reportProject => 'By project';

  @override
  String get reportSpendingRequests => 'By spending requests';

  @override
  String get reportWages => 'By wages';

  @override
  String get reportTasks => 'By tasks';

  @override
  String get expenseReportsEmpty => 'No expense requests yet';

  @override
  String get expenseReportUncategorized => 'Expense request';

  @override
  String get expenseReportAmount => 'Amount (UZS)';

  @override
  String get expenseReportUser => 'Employee';

  @override
  String get expenseReportAccountant => 'Accountant';

  @override
  String get expenseReportProject => 'Project';

  @override
  String get expenseReportCategory => 'Expense category';

  @override
  String get expenseReportType => 'Expense type';

  @override
  String get expenseReportPaymentMethod => 'Payment method';

  @override
  String get expenseReportPaymentCash => 'Cash';

  @override
  String get expenseReportPaymentCard => 'By card number';

  @override
  String get expenseReportCard => 'Card number';

  @override
  String get expenseReportCreatedAt => 'Created at';

  @override
  String get expenseReportPaidAt => 'Paid at';

  @override
  String get expenseReportConfirmedAt => 'Confirmed at';

  @override
  String get expenseReportCancelledAt => 'Cancelled at';

  @override
  String get expenseReportReason => 'Request reason';

  @override
  String get expenseReportCancelReason => 'Cancellation reason';

  @override
  String get expenseReportStatusPending => 'Pending';

  @override
  String get expenseReportStatusPaid => 'Paid';

  @override
  String get expenseReportStatusConfirmed => 'Confirmed';

  @override
  String get expenseReportStatusCancelled => 'Cancelled';

  @override
  String get expenseReportTypeWithdrawal => 'Withdrawal';

  @override
  String get expenseReportTypeCompany => 'Company expenses';

  @override
  String get expenseReportTypeOther => 'Other expenses';

  @override
  String get expenseReportSelect => 'Select';

  @override
  String get expenseReportAccountantHint => 'Select accountants';

  @override
  String get expenseReportProjectHint => 'Select project';

  @override
  String get expenseReportTitle => 'Title';

  @override
  String get expenseReportTitleHint => 'Search by title';

  @override
  String get taskReportsEmpty => 'No tasks yet';

  @override
  String get payrollReportsEmpty => 'No payroll reports yet';

  @override
  String get payrollFixedSalary => 'Fixed salary (UZS)';

  @override
  String get payrollKpiBonus => 'KPI bonus (UZS)';

  @override
  String get payrollPenalty => 'Penalty amount (UZS)';

  @override
  String get payrollTotal => 'Total amount (UZS)';

  @override
  String get payrollCreatedAt => 'Calculated at';

  @override
  String get payrollMonth => 'Month';

  @override
  String get payrollStatusCalculated => 'Calculated';

  @override
  String get payrollStatusConfirmed => 'Confirmed';

  @override
  String get taskReportAssignees => 'Assignees';

  @override
  String get taskReportAssigneesHint => 'Select assignees';

  @override
  String get taskReportSprint => 'Sprint number';

  @override
  String get taskReportPrice => 'Task price (UZS)';

  @override
  String get taskReportPenalty => 'Penalty (%)';

  @override
  String get taskReportReopened => 'Reopen count';

  @override
  String get reportsEmployeeEmpty => 'No employees yet';

  @override
  String get reportFixedSalary => 'Fixed salary (UZS):';

  @override
  String get reportBalance => 'Balance (UZS):';

  @override
  String get reportProjects => 'Projects';

  @override
  String get reportCompleted => 'Completed';

  @override
  String get reportTasksCount => 'Tasks';

  @override
  String get reportTodo => 'Todo';

  @override
  String get reportMeetings => 'Meetings';

  @override
  String get reportExpenseRequests => 'Expense request (UZS):';

  @override
  String get reportPaid => 'Paid';

  @override
  String get reportPayroll => 'Payroll (UZS):';

  @override
  String get reportKpiBonus => 'KPI bonus';

  @override
  String get reportFilterDateRange => 'Joined date';

  @override
  String get reportFilterPosition => 'Position';

  @override
  String get reportFilterPositionHint => 'Select position';

  @override
  String get reportFilterRegion => 'Region';

  @override
  String get reportFilterRegionHint => 'Select region';

  @override
  String get reportFilterEmployees => 'Employees';

  @override
  String get reportFilterEmployeesHint => 'Select employees';

  @override
  String get reportFilterSalary => 'Fixed salary (UZS)';

  @override
  String get reportFilterBalance => 'Balance (UZS)';

  @override
  String get reportFilterExpense => 'Expense request (UZS)';

  @override
  String get reportFilterPayroll => 'Payroll (UZS)';

  @override
  String get reportFilterFrom => 'from';

  @override
  String get reportFilterTo => 'to';

  @override
  String get reportFilterStatusAll => 'All';

  @override
  String get reportFilterGenerate => 'Generate';

  @override
  String get reportExpenseStatusPending => 'Pending';

  @override
  String get reportExpenseStatusConfirmed => 'Confirmed';

  @override
  String get reportExpenseStatusPaidUnconfirmed => 'Paid (unconfirmed)';

  @override
  String get reportPayrollTypePenalty => 'Penalty amount';

  @override
  String get reportsProjectEmpty => 'No projects yet';

  @override
  String get reportAuthor => 'Author:';

  @override
  String get reportManager => 'Manager:';

  @override
  String get reportEmployeesLabel => 'Employees:';

  @override
  String get reportTestersLabel => 'Testers:';

  @override
  String get reportManagerBonus => 'Manager bonus (UZS):';

  @override
  String get reportStatusLabel => 'Status:';

  @override
  String get reportFilterManagerBonus => 'Manager bonus';

  @override
  String get reportFilterAuthor => 'Author';

  @override
  String get reportFilterAuthorHint => 'Select author';

  @override
  String get reportFilterManager => 'Manager';

  @override
  String get reportFilterManagerHint => 'Select manager';

  @override
  String get reportFilterTesters => 'Testers';

  @override
  String get reportFilterTestersHint => 'Select testers';

  @override
  String get statPeriodSelect => 'Select period';

  @override
  String get statPeriod1Month => '1 month';

  @override
  String get statPeriod3Months => '3 months';

  @override
  String get statPeriod6Months => '6 months';

  @override
  String get statPeriod1Year => '1 year';

  @override
  String get statTasksTitle => 'Tasks';

  @override
  String get statTaskTodo => 'To do';

  @override
  String get statTaskInProgress => 'In progress';

  @override
  String get statTaskDone => 'Done';

  @override
  String get statTaskProduction => 'In production';

  @override
  String get statTaskChecked => 'Checked';

  @override
  String get statTaskRejected => 'Rejected';

  @override
  String get statTaskOverdue => 'Overdue';

  @override
  String get statProjectsTitle => 'Projects';

  @override
  String get statProjectCompleted => 'Completed';

  @override
  String get statProjectActive => 'Active';

  @override
  String get statProjectCancelled => 'Cancelled';

  @override
  String get statProjectOverdue => 'Overdue';

  @override
  String get statProjectPlanning => 'Planning';

  @override
  String get statMeetingsTitle => 'Meetings dynamics';

  @override
  String get statMeetingAttended => 'Attended';

  @override
  String get statMeetingExcused => 'Excused';

  @override
  String get statMeetingUnexcused => 'Unexcused';

  @override
  String get statEmpty => 'No data';

  @override
  String profileTitle(String role) {
    return '$role information';
  }

  @override
  String get profileRoleManage => 'Manage role';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileTheme => 'Design theme';

  @override
  String get profileAbout => 'About app';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String roleSwitchedTitle(String role) {
    return 'Switched to $role.';
  }

  @override
  String get profilePersonalInfo => 'Personal account';

  @override
  String profileLinkLabel(int index) {
    return 'Link $index';
  }

  @override
  String get profileSave => 'Save';

  @override
  String get profileUpdateSuccess => 'Information updated';

  @override
  String get profilePhoneInvalid =>
      'Enter phone number in +998XXXXXXXXX format';

  @override
  String get profileDistrictRequired =>
      'Select a district after selecting a region.';

  @override
  String roleSwitchedSubtitle(String role) {
    return 'You are now working as $role.';
  }

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get dailyPlansTitle => 'Daily plans';

  @override
  String get dailyPlansAdd => 'Add task';

  @override
  String get dailyPlansSubtitle => 'Create a task for yourself.';

  @override
  String get dailyPlansEmpty => 'No daily plans yet';

  @override
  String get dailyPlansNameHint => 'Enter plan name';

  @override
  String get dailyPlansItemHint => 'Add subtask...';

  @override
  String get dailyPlansEdit => 'Edit';

  @override
  String get dailyPlansDelete => 'Delete';

  @override
  String get dailyPlansDeleteTitle => 'Delete plan';

  @override
  String get dailyPlansDeleteMessage => 'This action cannot be undone.';

  @override
  String get dailyPlansCancel => 'Cancel';

  @override
  String get dailyPlansSave => 'Save';

  @override
  String get dailyPlansSaved => 'Plan saved';

  @override
  String get dailyPlansDeleted => 'Plan deleted';

  @override
  String get dailyPlansDone => 'Done';

  @override
  String get dailyPlansUndone => 'Not done';

  @override
  String get dailyPlansMyTasks => 'My tasks';

  @override
  String get dailyPlansTaskName => 'Task name';

  @override
  String get dailyPlansDeadline => 'Deadline';

  @override
  String get dailyPlansToday => 'Today';

  @override
  String get dailyPlansTomorrow => 'Tomorrow';

  @override
  String get dailyPlansEditTask => 'Edit task';

  @override
  String get taskAdd => 'Add task';

  @override
  String get tasksEmpty => 'No tasks yet';

  @override
  String get taskPriorityLow => 'Low';

  @override
  String get taskPriorityMedium => 'Medium';

  @override
  String get taskPriorityHigh => 'High';

  @override
  String get taskPriorityCritical => 'Critical';

  @override
  String get taskCreateTitle => 'Add task';

  @override
  String get taskCreateFieldProject => 'Project';

  @override
  String get taskCreateProjectHint => 'Select a project';

  @override
  String get taskCreateFieldName => 'Name';

  @override
  String get taskCreateNameHint => 'Enter a name';

  @override
  String get taskCreateFieldDescription => 'Description';

  @override
  String get taskCreateDescriptionHint => 'Write a description';

  @override
  String get taskCreateFieldPriority => 'Priority';

  @override
  String get taskCreatePriorityHint => 'Select priority';

  @override
  String get taskCreateFieldType => 'Type';

  @override
  String get taskCreateTypeHint => 'Select type';

  @override
  String get taskTypeBug => 'Bug';

  @override
  String get taskTypeFeature => 'New feature';

  @override
  String get taskTypeAddition => 'Addition';

  @override
  String get taskTypeResearch => 'Research/Study';

  @override
  String get taskCreateFieldAssigner => 'Assigner';

  @override
  String get taskCreateSelectProjectFirst => 'Select a project first';

  @override
  String get taskCreateFieldPositions => 'For whom';

  @override
  String get taskCreatePositionsHint => 'Select';

  @override
  String get taskCreateFieldSprint => 'Sprint';

  @override
  String get taskCreateFieldPrice => 'Task price (UZS)';

  @override
  String get taskCreatePriceHint => '0.00';

  @override
  String get taskCreateFieldPenalty => 'Penalty rate (%)';

  @override
  String get taskCreatePenaltyHint => 'Penalty';

  @override
  String get taskCreateFieldDeadline => 'Deadline';

  @override
  String get taskCreateFieldTime => 'Time';

  @override
  String get taskCreateFieldEstimated => 'Estimated time';

  @override
  String get taskCreateFieldFiles => 'Additional files';

  @override
  String get taskCreateFileUpload => 'Upload file';

  @override
  String get taskCreateRequiredError =>
      'Project, name and deadline are required';

  @override
  String get taskDeadlineChangeRequired => 'Change the deadline';

  @override
  String get taskCreateSuccess => 'Task created';

  @override
  String get taskEditTitle => 'Edit task';

  @override
  String get taskEditSave => 'Save';

  @override
  String get taskUpdateSuccess => 'Task updated';

  @override
  String get taskDetailTitle => 'Details';

  @override
  String get taskDetailCreatedBy => 'Assigner';

  @override
  String get taskDetailRejectReason => 'Rejection reason';

  @override
  String get taskActionChecked => 'Checked';

  @override
  String get taskActionRejected => 'Rejected';

  @override
  String get taskActionInProgress => 'Move to in progress';

  @override
  String get taskActionMarkDone => 'Mark as done';

  @override
  String get taskActionProduction => 'Move to production';

  @override
  String get taskActionEditDeadline => 'Change deadline';

  @override
  String get taskRejectTitle => 'Reject task';

  @override
  String get taskRejectSubtitle => 'Enter the rejection reason';

  @override
  String get taskRejectHint => 'Write the reason...';

  @override
  String get taskRejectConfirm => 'Delete';

  @override
  String get taskStatusUpdated => 'Status updated';

  @override
  String get meetingEditTitle => 'Edit meeting';

  @override
  String get meetingDetailTitle => 'Meeting details';

  @override
  String get meetingDetailParticipantsLabel => 'Meeting participants';

  @override
  String get meetingUpdateSuccess => 'Meeting updated';

  @override
  String get meetingCloseAction => 'Finish meeting';

  @override
  String get meetingCloseSheetTitle => 'Mark meeting participants';

  @override
  String get meetingCloseSheetSubtitle => 'Select attended employees';

  @override
  String get meetingCloseConfirm => 'Confirm';

  @override
  String get meetingCloseSuccess => 'Meeting completed';

  @override
  String get meetingExcuseListTitle => 'Absence reasons';

  @override
  String get meetingExcuseNoReason => 'No reason submitted yet';

  @override
  String get meetingExcuseAccepted => 'Excuse accepted';

  @override
  String get meetingExcuseReject => 'Reject';

  @override
  String get meetingExcuseRejected => 'Rejected';

  @override
  String get meetingMyAttended => 'You attended this meeting';

  @override
  String get meetingMyNotAttended => 'You did not attend this meeting';

  @override
  String get meetingSendReason => 'Send reason';

  @override
  String get meetingReasonSentLabel => 'Reason sent';

  @override
  String get meetingDeleteTitle => 'Delete meeting';

  @override
  String get meetingDeleteSubtitle =>
      'The meeting will be moved to the trash and can be restored later.';

  @override
  String get projectCreateFilesLabel => 'Project documents';

  @override
  String get projectExistingFilesLabel => 'Existing documents';

  @override
  String get projectCreateDocsFailed =>
      'Project created, but some documents failed to save';

  @override
  String get projectUpdateDocsFailed =>
      'Project saved, but some documents failed to save';

  @override
  String get projectDocumentNameHint => 'Enter name';

  @override
  String get projectDocumentLinkHint => 'Link';

  @override
  String get projectDocumentAddButton => 'Add document';

  @override
  String get projectDocumentLinkCopied => 'Link copied';

  @override
  String get taskMenuDetails => 'Details';

  @override
  String get taskMenuDelete => 'Delete';

  @override
  String get taskDeleteTitle => 'Delete task';

  @override
  String get taskDeleteSubtitle =>
      'The task will be moved to the trash and can be restored later.';

  @override
  String get taskDeleteCancel => 'Cancel';

  @override
  String get taskFilterTitle => 'Filter';

  @override
  String get taskFilterStatus => 'Status';

  @override
  String get taskFilterAllStatuses => 'All';

  @override
  String get taskFilterStatusHint => 'Select status';

  @override
  String get taskStatusTodo => 'To do';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusOverdue => 'Overdue';

  @override
  String get taskStatusDone => 'Done';

  @override
  String get taskStatusProduction => 'In production';

  @override
  String get taskStatusChecked => 'Checked';

  @override
  String get taskStatusRejected => 'Rejected';

  @override
  String get taskFilterAuthor => 'Author';

  @override
  String get taskFilterAuthorHint => 'Select author';

  @override
  String get taskFilterEmployee => 'Employee';

  @override
  String get taskFilterEmployeeHint => 'Select employee';

  @override
  String get taskFilterDeadlineRange => 'Deadline range';

  @override
  String get taskFilterDateHint => 'Date';

  @override
  String get taskFilterReset => 'Clear';

  @override
  String get taskFilterApply => 'Search';

  @override
  String get taskSearchHint => 'Search';

  @override
  String get taskSearchClose => 'Close';

  @override
  String get taskFilterSelectAdd => 'Add';

  @override
  String taskFilterSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectAdd => 'Add project';

  @override
  String get projectsEmpty => 'No projects yet';

  @override
  String get projectSearchHint => 'Search projects';

  @override
  String get projectFilterManager => 'Manager';

  @override
  String get projectFilterManagerHint => 'Select manager';

  @override
  String get projectFilterTitleField => 'Title';

  @override
  String get projectFilterTitleHint => 'Search by title';

  @override
  String get projectCreateDefaultPrefix => 'ERAF';

  @override
  String get projectCreateDefaultPenalty => '20';

  @override
  String get projectCreateManagerBonus => 'Manager bonus';

  @override
  String get projectCreateManagerBonusHint => 'For project: 0.0';

  @override
  String get projectCreatePrefixHint => 'Enter title';

  @override
  String get projectCreateEmployees => 'Employees';

  @override
  String get projectCreateEmployeesHint => 'Select employee';

  @override
  String get projectUpdateSuccess => 'Project updated';

  @override
  String get projectDetailsTitle => 'Project details';

  @override
  String get projectEditTitle => 'Edit project';

  @override
  String get projectMenuEdit => 'Edit';

  @override
  String get projectMenuDetails => 'Details';

  @override
  String get projectMenuDelete => 'Delete';

  @override
  String get projectDeleteTitle => 'Delete project';

  @override
  String get projectDeleteSubtitle =>
      'Do you really want to delete the project? You can restore the deleted project from the trash.';

  @override
  String get projectDeleteCancel => 'Cancel';

  @override
  String get projectCreateTesters => 'Testers';

  @override
  String get projectCreateTestersHint => 'Select tester';

  @override
  String get projectCreateActive => 'Active?';

  @override
  String get projectCreateRequiredError =>
      'Name, title, manager and deadline are required';

  @override
  String get projectCreateSuccess => 'Project created';

  @override
  String get projectStatusPlanning => 'Planning';

  @override
  String get projectStatusActive => 'Active';

  @override
  String get projectStatusOverdue => 'Overdue';

  @override
  String get projectStatusCompleted => 'Completed';

  @override
  String get projectStatusCancelled => 'Cancelled';

  @override
  String get meetingsTitle => 'Meetings';

  @override
  String get meetingAdd => 'Add meeting';

  @override
  String get meetingsEmpty => 'No meetings yet';

  @override
  String get meetingFilterOrganizer => 'Organizer';

  @override
  String get meetingFilterOrganizerHint => 'Select organizer';

  @override
  String get meetingFilterStartDateRange => 'Start date range';

  @override
  String get meetingCreateNameHint => 'Enter a name';

  @override
  String get meetingCreatePenaltyHint => 'Enter penalty rate';

  @override
  String get meetingCreateLink => 'Link';

  @override
  String get meetingCreateLinkHint => 'Enter link: URL address';

  @override
  String get meetingCreateDescriptionHint => 'Write a description';

  @override
  String get meetingCreateStartDate => 'Deadline date';

  @override
  String get meetingCreateDuration => 'Duration';

  @override
  String get meetingCreateDurationHint => 'Minutes';

  @override
  String get meetingCreateParticipantsLabel => 'Add meeting participants';

  @override
  String get meetingCreateParticipantsHelp =>
      'Search and select using the button below';

  @override
  String get meetingCreateParticipantsAdd => 'Add participants';

  @override
  String get meetingCreateParticipantsTitle => 'Add participants';

  @override
  String get meetingPreviewDetailsTitle => 'Meeting details';

  @override
  String get meetingPreviewApprovalTitle => 'Approval required';

  @override
  String get meetingPreviewApprovalDescription =>
      'When enabled, the creator, project manager or admin must approve each participant.';

  @override
  String get meetingPreviewActive => 'In progress';

  @override
  String get meetingPreviewJoin => 'Join meeting';

  @override
  String get meetingPreviewSave => 'Save';

  @override
  String get meetingPreviewProject => 'Marketing Platform';

  @override
  String get meetingPreviewProjectSecond => 'Digital Control';

  @override
  String get meetingPreviewName => 'Test meeting';

  @override
  String get meetingPreviewPenalty => '20';

  @override
  String get meetingPreviewDescription =>
      'Add a new “Reports” section to the CRM system. Admin must be able to see all data.';

  @override
  String get meetingPreviewParticipantOne => 'Ali Valiyev';

  @override
  String get meetingPreviewParticipantTwo => 'Madina Karimova';

  @override
  String get meetingCreateCompleted => 'Completed?';

  @override
  String get meetingCreateRequiredError =>
      'Project, name, link, description, date and duration are required';

  @override
  String get meetingCreateSuccess => 'Meeting created';

  @override
  String get meetingReasonTitle => 'You missed the meeting';

  @override
  String get meetingReasonPrompt => 'Please enter the reason for your absence';

  @override
  String get meetingReasonHint => 'Write the reason...';

  @override
  String get meetingReasonSubmit => 'Submit';

  @override
  String get meetingReasonSentTitle => 'Reason submitted.';

  @override
  String get profileLogoutTitle => 'Do you want to log out?';

  @override
  String get profileLogoutSubtitle =>
      'You will be logged out and will need to log in again to access your profile.';

  @override
  String get profileLogoutBack => 'Back';

  @override
  String get profileLogoutConfirm => 'Log out';

  @override
  String get profileThemeSheetTitle => 'Design theme';

  @override
  String get profileThemeSheetSubtitle => 'Choose how the app should look.';

  @override
  String get profileThemeLight => 'Light mode';

  @override
  String get profileThemeDark => 'Dark mode';

  @override
  String get securityChangePassword => 'Change password';

  @override
  String get securityAutoLock => 'Auto-lock';

  @override
  String get securityAutoLockSubtitle =>
      'PIN must be entered again after inactivity.';

  @override
  String get securityAutoLockImmediately => 'Immediately';

  @override
  String get securityAutoLock1Minute => '1 minute';

  @override
  String get securityAutoLock5Minutes => '5 minutes';

  @override
  String get securityAutoLock15Minutes => '15 minutes';

  @override
  String get securityAutoLock30Minutes => '30 minutes';

  @override
  String get securityAutoLock1Hour => '1 hour';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordSubtitle =>
      'For security, enter your current password and set a new one.';

  @override
  String get changePasswordOldLabel => 'Current password';

  @override
  String get changePasswordOldHint => 'Enter your current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordNewHint => 'Enter a new password';

  @override
  String get changePasswordConfirmLabel => 'Confirm password';

  @override
  String get changePasswordConfirmHint => 'Re-enter the new password';

  @override
  String get changePasswordErrorOldWrong => 'Current password is incorrect';

  @override
  String get changePasswordErrorMismatch => 'Passwords do not match';

  @override
  String get changePasswordCancel => 'Cancel';

  @override
  String get changePasswordSave => 'Save';

  @override
  String get changePasswordSuccess => 'Password changed successfully.';

  @override
  String get commonError => 'Something went wrong. Please try again later.';

  @override
  String get networkError => 'No internet connection. Check your connection.';

  @override
  String get usersEmpty => 'No users yet';

  @override
  String get userFullNameLabel => 'Full name:';

  @override
  String get userPositionLabel => 'Position:';

  @override
  String get userRoleLabel => 'Role:';

  @override
  String get userSalaryLabel => 'Salary:';

  @override
  String get userBalanceLabel => 'Balance:';

  @override
  String get usersFilterAllPositions => 'All positions';

  @override
  String get usersFilterAllRoles => 'All roles';

  @override
  String get usersSortNameAsc => 'A to Z';

  @override
  String get usersSortNameDesc => 'Z to A';

  @override
  String get usersSortNewest => 'New → Old';

  @override
  String get usersSortOldest => 'Old → New';

  @override
  String get userCreateTitle => 'Add new employee';

  @override
  String get userCreateNameHint => 'Enter full name';

  @override
  String get userCreatePassword => 'Password';

  @override
  String get userCreateConfirmPassword => 'Confirm password';

  @override
  String get userCreatePasswordMismatch => 'Passwords do not match';

  @override
  String get userCreateSalaryInvalid => 'Check salary format';

  @override
  String get userCreateDistrictHint => 'Select district';

  @override
  String get userCreateAvatarUpload => 'Upload avatar';

  @override
  String get userCreateImageUpload => 'Upload image';

  @override
  String get userCreateLinkHint => 'Enter link';

  @override
  String get userCreateSubmit => 'Add';

  @override
  String get userCreateSuccess => 'User added';

  @override
  String get userCreateRequiredError => 'Fill in required fields';

  @override
  String get userDetailTitle => 'User details';

  @override
  String get userDetailFullName => 'Full name';

  @override
  String get userDetailCreatedAt => 'Created at';

  @override
  String get userDetailPhone => 'Phone number';

  @override
  String get userDetailCard => 'Card number';

  @override
  String get userDetailSalary => 'Monthly salary';

  @override
  String get userDetailBalance => 'Balance';

  @override
  String get userDetailDistrict => 'District';

  @override
  String get userDetailPassport => 'Passport details';

  @override
  String get userDetailPassportImage => 'Passport image';

  @override
  String get userDetailPosition => 'Position';

  @override
  String get userDetailRole => 'Role';

  @override
  String get financeExpenseRequests => 'Expense requests';

  @override
  String get financeWages => 'Wages';

  @override
  String get financeHistory => 'History';

  @override
  String get ledgerEmpty => 'No records yet';

  @override
  String get ledgerTypeLabel => 'Type:';

  @override
  String get ledgerAmountLabel => 'Amount:';

  @override
  String get ledgerDateLabel => 'Date:';

  @override
  String get ledgerTypeExpense => 'Expense';

  @override
  String get ledgerTypeIncome => 'Income';

  @override
  String get ledgerDetailTitle => 'History details';

  @override
  String get ledgerDetailExpenseType => 'Expense type';

  @override
  String get ledgerDetailAmount => 'Amount';

  @override
  String get ledgerDetailConfirmedAt => 'Confirmed at';

  @override
  String get ledgerFilterExpenseType => 'Expense type';

  @override
  String get ledgerFilterExpenseTypeHint => 'Select expense type';

  @override
  String get ledgerFilterDateRange => 'Date range';

  @override
  String get ledgerFilterAmount => 'Amount';

  @override
  String get payrollEmpty => 'No records yet';

  @override
  String get payrollMonthLabel => 'Month:';

  @override
  String get payrollKpiLabel => 'KPI bonus:';

  @override
  String get payrollTotalLabel => 'Total:';

  @override
  String get payrollDetailTitle => 'Payroll details';

  @override
  String get payrollMonthField => 'Month';

  @override
  String get payrollSalaryField => 'Monthly salary (UZS)';

  @override
  String get payrollKpiField => 'KPI bonus';

  @override
  String get payrollPenaltyField => 'Penalty amount';

  @override
  String get payrollTotalField => 'Total amount';

  @override
  String get payrollConfirmButton => 'Confirm';

  @override
  String get payrollConfirmSuccess => 'Payroll confirmed';

  @override
  String get payrollConfirmDialogTitle => 'Confirm this payroll?';

  @override
  String get payrollConfirmDialogSubtitle =>
      'This action cannot be undone once confirmed';

  @override
  String get payrollFilterMonth => 'Month';

  @override
  String get payrollFilterMonthHint => 'Select month';

  @override
  String get payrollFilterCreatedRange => 'Created date range';

  @override
  String get payrollFilterTotal => 'Total amount (UZS)';

  @override
  String get payrollFilterPenalty => 'Penalty amount';

  @override
  String get payrollFilterApply => 'Search';

  @override
  String get expenseRequestProjectLabel => 'Project:';

  @override
  String get expenseRequestTypeLabel => 'Expense type:';

  @override
  String get expenseRequestAmountLabel => 'Amount:';

  @override
  String get expenseRequestFilterCategory => 'Category';

  @override
  String get expenseRequestFilterCategoryHint => 'Select category';

  @override
  String get expenseRequestFilterAmount => 'Amount';

  @override
  String get expenseRequestFilterPaidRange => 'Paid time range';

  @override
  String get expenseRequestFilterConfirmedRange => 'Confirmed time range';

  @override
  String get expenseRequestDetailTitle => 'Request details';

  @override
  String get expenseRequestAmountField => 'Amount (UZS)';

  @override
  String get expenseRequestReasonField => 'Reason';

  @override
  String get expenseRequestPayButton => 'I paid';

  @override
  String get expenseRequestPayDialogTitle =>
      'Confirm that the payment was made?';

  @override
  String get expenseRequestPayDialogSubtitle =>
      'This records the payment as completed in the system.';

  @override
  String get expenseRequestCancelReasonHint =>
      'Please write the reason. It is required';

  @override
  String get expenseRequestPaySuccess => 'Payment recorded.';

  @override
  String get expenseRequestPaySuccessMessage =>
      'The disbursement has been marked in the system.';

  @override
  String get expenseRequestCancelSuccess => 'Request rejected.';

  @override
  String get expenseRequestCancelSuccessMessage =>
      'The rejection reason for the request has been saved.';

  @override
  String get expenseRequestReceiptDialogTitle => 'Upload the payment receipt.';

  @override
  String get expenseRequestReceiptDialogSubtitle =>
      'Upload a receipt or invoice to confirm the payment.';

  @override
  String get expenseRequestReceiptInfo =>
      'You can upload the receipt file now or add it later.';

  @override
  String get expenseRequestReceiptAddTile => 'Upload payment receipt';

  @override
  String get expenseRequestReceiptSkip => 'Skip';

  @override
  String get expenseRequestReceiptSend => 'Send';

  @override
  String get expenseRequestReceiptsTitle => 'Payment receipts';

  @override
  String get expenseRequestReceiptViewerTitle => 'Payment receipt';

  @override
  String get expenseRequestStatusRejected => 'Rejected';

  @override
  String get expenseRequestConfirmButton => 'Confirm';

  @override
  String get expenseRequestConfirmSuccess => 'Request confirmed.';

  @override
  String get expenseRequestConfirmSuccessMessage =>
      'The confirmation has been recorded in the system.';

  @override
  String get expenseRequestCardCopied => 'Card number copied';

  @override
  String get expenseRequestCreateTitle => 'Submit request';

  @override
  String get expenseRequestCreateSubmit => 'Submit request';

  @override
  String get expenseRequestCreateProjectLabel => 'For project';

  @override
  String get expenseRequestCreateAmountLabel => 'Amount';

  @override
  String get expenseRequestCreateAmountHint => 'Enter amount: 0.00';

  @override
  String get expenseRequestCreateReasonHint => 'Write the reason';

  @override
  String get expenseRequestCreatePaymentHint => 'Select payment method';

  @override
  String get expenseRequestCreateCardLabel => 'Card number';

  @override
  String get expenseRequestCreateCardHint => 'Enter card number';

  @override
  String get expenseRequestCreateValidation =>
      'Please fill in the required fields.';

  @override
  String get expenseRequestCreateSuccess => 'Request submitted.';

  @override
  String get expenseRequestCreateSuccessMessage =>
      'Your expense request was submitted successfully.';

  @override
  String get meetingCallJoinTitle => 'Join meeting';

  @override
  String get meetingCallWaitingTitle => 'Waiting for approval';

  @override
  String get meetingCallCameraOff => 'Camera is off';

  @override
  String get meetingCallMicrophone => 'Microphone';

  @override
  String get meetingCallCamera => 'Camera';

  @override
  String get meetingCallSampleTitle => 'Weekly project meeting';

  @override
  String get meetingCallCodeCopied => 'Meeting code copied';

  @override
  String get meetingCallJoin => 'Join';

  @override
  String get meetingCallApprovalHint =>
      'You will enter when the organizer approves you.';

  @override
  String get meetingCallRequestSent => 'Request sent';

  @override
  String get meetingCallWaitingHint =>
      'You will enter automatically when the organizer approves you.';

  @override
  String get meetingCallCancel => 'Cancel';

  @override
  String get meetingCallPreviewApprove => 'Demo: approve request';

  @override
  String get meetingCallName => 'Meeting name';

  @override
  String get meetingCallEnd => 'End meeting';

  @override
  String get meetingCallLeave => 'Leave';

  @override
  String get meetingCallYou => 'You';

  @override
  String get meetingCallSelfName => 'Safarali Turotov (you)';

  @override
  String get meetingCallDilnoza => 'Dilnoza Sattorova';

  @override
  String get meetingCallBekzod => 'Bekzod Qodirov';

  @override
  String get meetingCallRaisedNotice => 'Dilnoza Sattorova raised a hand';

  @override
  String get meetingCallWantsToJoin => 'wants to join the meeting';

  @override
  String get meetingCallReject => 'Reject';

  @override
  String get meetingCallAllow => 'Allow';

  @override
  String get meetingCallRaiseHand => 'Raise hand';

  @override
  String get meetingCallMore => 'More';

  @override
  String get meetingCallParticipantsCount => 'Participants (3)';

  @override
  String get meetingCallParticipants => 'Participants';

  @override
  String get meetingCallChat => 'Chat';

  @override
  String get meetingCallClose => 'Close';

  @override
  String get meetingCallSearch => 'Search';

  @override
  String get meetingCallInMeeting => 'IN THE MEETING';

  @override
  String get meetingCallOrganizer => 'Organizer';

  @override
  String get meetingCallParticipant => 'Participant';

  @override
  String get meetingCallChatNote =>
      'Messages are deleted when the meeting ends.';

  @override
  String get meetingCallSampleMessageOne => 'Please share the report on screen';

  @override
  String get meetingCallSampleMessageTwo => 'One minute, I\'ll share it';

  @override
  String get meetingCallMessageHint => 'Write a message';

  @override
  String get meetingCallShareScreen => 'Share screen';

  @override
  String get meetingCallStickers => 'Stickers';

  @override
  String get meetingCallMicAndSpeaker => 'Microphone and speaker';

  @override
  String get meetingCallMicrophoneSection => 'MICROPHONE';

  @override
  String get meetingCallSpeakerSection => 'SPEAKER';

  @override
  String get meetingCallIphoneMicrophone => 'iPhone microphone';

  @override
  String get meetingCallAirpods => 'AirPods Pro';

  @override
  String get meetingCallWiredHeadset => 'Wired headset';

  @override
  String get meetingCallIphoneSpeaker => 'iPhone speaker';

  @override
  String get meetingCallExitQuestion => 'Leave the meeting?';

  @override
  String get meetingCallExitHint =>
      'The link will remain active, so you can join again at any time.';

  @override
  String get meetingCallEndForEveryone => 'End the meeting for everyone';

  @override
  String get meetingCallMeetingEndedTitle => 'You left the meeting';

  @override
  String get meetingCallMeetingEndedHint =>
      'The link is still active, so you can return at any time.';

  @override
  String get meetingCallRejoin => 'Rejoin';

  @override
  String get meetingCallHome => 'Home page';

  @override
  String get meetingCallDetails => 'Meeting details';

  @override
  String get meetingCallDetailsHint => 'Link and official information';

  @override
  String get meetingCallJoinDetails => 'JOINING INFORMATION';

  @override
  String get meetingCallMeetingLink => 'Meeting link';

  @override
  String get meetingCallMeetingParams => 'MEETING PARAMETERS';

  @override
  String get meetingCallOfficialUid => 'Official UID';

  @override
  String get meetingCallMeetingTopic => 'Meeting topic';

  @override
  String get meetingCallStartTime => 'Start time';

  @override
  String get meetingCallSecurityAccess => 'Security and access';

  @override
  String get meetingCallDirectJoin => 'Direct join';

  @override
  String get meetingCallMeetingUid => 'MT-0005';

  @override
  String get meetingCallTopicValue => 'Review Figma';

  @override
  String get meetingCallStartValue => '14.09.2026 15:40, 30 minutes';

  @override
  String get meetingCallYouAreSharing => 'You are sharing your screen';

  @override
  String get meetingCallStopSharing => 'Stop sharing';

  @override
  String get meetingCallChooseAnotherScreen => 'Choose another screen';

  @override
  String get meetingCallChatEmpty => 'No messages yet';

  @override
  String get meetingCallChatEmptyHint => 'You can write during the meeting';

  @override
  String get meetingCallCameraAndBackground => 'Camera and background';

  @override
  String get meetingCallCameraSection => 'CAMERA';

  @override
  String get meetingCallFrontCamera => 'Front camera';

  @override
  String get meetingCallRearCamera => 'Rear camera';

  @override
  String get meetingCallBackgroundSection => 'BACKGROUND';

  @override
  String get meetingCallBlurBackground => 'Blur background';

  @override
  String get meetingCallNoBackground => 'No background';

  @override
  String get meetingCallOfficeBackgrounds => 'Office backgrounds';

  @override
  String get meetingCallSearchParticipant => 'Search participant';

  @override
  String get meetingCallMicRequestTitle => 'Turn on your microphone?';

  @override
  String get meetingCallCameraRequestTitle => 'Turn on your camera?';

  @override
  String get meetingCallRequester => 'Safarali Turotov';

  @override
  String get meetingCallOrganizerRequested => 'Organizer just asked';

  @override
  String get meetingCallMicRequestHint =>
      'The choice is yours. If you are not ready, you can turn it on later.';

  @override
  String get meetingCallCameraRequestHint =>
      'The choice is yours. If you prefer, you can keep your camera off.';

  @override
  String get meetingCallNotNow => 'Not now';

  @override
  String get meetingCallEnableMicrophone => 'Turn on microphone';

  @override
  String get meetingCallEnableCamera => 'Turn on camera';

  @override
  String get meetingCallStickersTitle => 'Stickers';

  @override
  String get meetingCallSendMessage => 'Send message';
}
