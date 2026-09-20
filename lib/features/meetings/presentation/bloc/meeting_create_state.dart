part of 'meeting_create_bloc.dart';

enum MeetingCreateSubmitStatus { idle, submitting, success, failure }

class MeetingCreateState extends Equatable {
  const MeetingCreateState({
    this.projects = const [],
    this.members = const [],
    this.membersLoading = false,
    this.detail,
    this.submittedMeeting,
    this.submitStatus = MeetingCreateSubmitStatus.idle,
    this.submitFailure,
    this.closeStatus = MeetingCreateSubmitStatus.idle,
    this.myAttendance,
    this.attendanceRows = const [],
    this.excuseBusyId = 0,
    this.rejectedExcuseIds = const {},
    this.excuseActionFailed = false,
  });

  final List<ProjectShort> projects;
  final List<ProjectMember> members;
  final bool membersLoading;

  /// `GET /meetings/{id}/` javobi (detail rejimi).
  final Meeting? detail;

  /// The server response from the latest create/update request.
  final Meeting? submittedMeeting;

  final MeetingCreateSubmitStatus submitStatus;
  final Failure? submitFailure;

  /// Yakunlash oqimi (davomat PATCH + close) holati — [submitStatus]dan
  /// alohida, chunki detail rejimida forma submit'i yo'q.
  final MeetingCreateSubmitStatus closeStatus;

  /// Joriy foydalanuvchining shu yig'ilishdagi qatnashuv yozuvi
  /// (detail rejimida ko'rsatiladi; `null` — yuklanmagan/topilmadi).
  final MeetingAttendance? myAttendance;

  /// Detail: yig'ilishning barcha qatnashuv yozuvlari — tashkilotchining
  /// sabab tasdiqlash/rad etish ro'yxati shu yerdan.
  final List<MeetingAttendance> attendanceRows;

  /// Hozir qaror yuborilayotgan attendance id (0 — yo'q).
  final int excuseBusyId;

  /// Shu sessiyada rad etilganlar (backend'da alohida maydon yo'q).
  final Set<int> rejectedExcuseIds;

  /// Oxirgi qaror urinishi xato (toast trigger).
  final bool excuseActionFailed;

  MeetingCreateState copyWith({
    List<ProjectShort>? projects,
    List<ProjectMember>? members,
    bool? membersLoading,
    Meeting? detail,
    Meeting? submittedMeeting,
    MeetingCreateSubmitStatus? submitStatus,
    Failure? submitFailure,
    MeetingCreateSubmitStatus? closeStatus,
    MeetingAttendance? myAttendance,
    List<MeetingAttendance>? attendanceRows,
    int? excuseBusyId,
    Set<int>? rejectedExcuseIds,
    bool? excuseActionFailed,
  }) => MeetingCreateState(
    projects: projects ?? this.projects,
    members: members ?? this.members,
    membersLoading: membersLoading ?? this.membersLoading,
    detail: detail ?? this.detail,
    submittedMeeting: submittedMeeting ?? this.submittedMeeting,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure ?? this.submitFailure,
    closeStatus: closeStatus ?? this.closeStatus,
    myAttendance: myAttendance ?? this.myAttendance,
    attendanceRows: attendanceRows ?? this.attendanceRows,
    excuseBusyId: excuseBusyId ?? this.excuseBusyId,
    rejectedExcuseIds: rejectedExcuseIds ?? this.rejectedExcuseIds,
    excuseActionFailed: excuseActionFailed ?? false,
  );

  @override
  List<Object?> get props => [
    projects,
    members,
    membersLoading,
    detail,
    submittedMeeting,
    submitStatus,
    submitFailure,
    closeStatus,
    myAttendance,
    attendanceRows,
    excuseBusyId,
    rejectedExcuseIds,
    excuseActionFailed,
  ];
}
