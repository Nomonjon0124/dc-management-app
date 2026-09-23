import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_project_members_usecase.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/entities/meeting_attendance_update.dart';
import '../../domain/entities/meeting_form.dart';
import '../../domain/usecases/close_meeting_usecase.dart';
import '../../domain/usecases/create_meeting_usecase.dart';
import '../../domain/usecases/get_meeting_attendance_usecase.dart';
import '../../domain/usecases/get_meeting_usecase.dart';
import '../../domain/usecases/update_meeting_attendance_usecase.dart';
import '../../domain/usecases/update_meeting_usecase.dart';

part 'meeting_create_event.dart';
part 'meeting_create_state.dart';

class MeetingCreateBloc extends Bloc<MeetingCreateEvent, MeetingCreateState> {
  MeetingCreateBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetProjectMembersUseCase getMembers,
    required GetMeetingUseCase getMeeting,
    required CreateMeetingUseCase createMeeting,
    required UpdateMeetingUseCase updateMeeting,
    required CloseMeetingUseCase closeMeeting,
    required GetMeetingAttendanceUseCase getAttendance,
    required UpdateMeetingAttendanceUseCase updateAttendance,
  }) : _getOptions = getOptions,
       _getMembers = getMembers,
       _getMeeting = getMeeting,
       _createMeeting = createMeeting,
       _updateMeeting = updateMeeting,
       _closeMeeting = closeMeeting,
       _getAttendance = getAttendance,
       _updateAttendance = updateAttendance,
       super(const MeetingCreateState()) {
    on<MeetingCreateOptionsRequested>(_onRequested);
    on<MeetingCreateProjectSelected>(_onProjectSelected);
    on<MeetingCreateParticipantsRequested>(_onParticipantsRequested);
    on<MeetingDetailRequested>(_onDetailRequested);
    on<MeetingCreateSubmitted>(_onSubmitted);
    on<MeetingUpdateSubmitted>(_onUpdateSubmitted);
    on<MeetingCloseWithAttendanceSubmitted>(_onCloseWithAttendance);
    on<MeetingMyAttendanceRequested>(_onMyAttendanceRequested);
    on<MeetingDetailExcuseDecided>(_onExcuseDecided);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetProjectMembersUseCase _getMembers;
  final GetMeetingUseCase _getMeeting;
  final CreateMeetingUseCase _createMeeting;
  final UpdateMeetingUseCase _updateMeeting;
  final CloseMeetingUseCase _closeMeeting;
  final GetMeetingAttendanceUseCase _getAttendance;
  final UpdateMeetingAttendanceUseCase _updateAttendance;

  Future<void> _onDetailRequested(
    MeetingDetailRequested event,
    Emitter<MeetingCreateState> emit,
  ) async {
    try {
      final meeting = await _getMeeting(event.id);
      emit(state.copyWith(detail: meeting));
    } on Failure catch (_) {
      // Yuklanmasa forma ro'yxatdan kelgan (extra) ma'lumotda qoladi.
    }
  }

  Future<void> _onRequested(
    MeetingCreateOptionsRequested event,
    Emitter<MeetingCreateState> emit,
  ) async {
    try {
      final options = await _getOptions();
      emit(state.copyWith(projects: options.projects));
    } on Failure catch (_) {
      // Tanlovlar yuklanmasa dropdown bo'sh qoladi.
    }
  }

  Future<void> _onProjectSelected(
    MeetingCreateProjectSelected event,
    Emitter<MeetingCreateState> emit,
  ) async {
    await _loadMembers(event.projectId, emit);
  }

  Future<void> _onParticipantsRequested(
    MeetingCreateParticipantsRequested event,
    Emitter<MeetingCreateState> emit,
  ) async {
    await _loadMembers(event.projectId, emit);
  }

  Future<void> _loadMembers(
    int projectId,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(membersLoading: true, members: const []));
    try {
      final members = await _getMembers(projectId);
      emit(state.copyWith(membersLoading: false, members: members));
    } on Failure catch (_) {
      emit(state.copyWith(membersLoading: false));
    }
  }

  Future<void> _onSubmitted(
    MeetingCreateSubmitted event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.submitting));
    try {
      final meeting = await _createMeeting(event.form);
      if (event.closeAfterCreate && meeting.id > 0) {
        await _closeMeeting(meeting.id);
      }
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.success,
          submittedMeeting: meeting,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }

  Future<void> _onMyAttendanceRequested(
    MeetingMyAttendanceRequested event,
    Emitter<MeetingCreateState> emit,
  ) async {
    try {
      final rows = await _getAttendance(event.meetingId);
      MeetingAttendance? mine;
      for (final row in rows) {
        if (row.userId == event.userId) {
          mine = row;
          break;
        }
      }
      emit(state.copyWith(myAttendance: mine, attendanceRows: rows));
    } on Failure catch (_) {
      // Yuklanmasa holat bo'limi ko'rsatilmaydi.
    }
  }

  /// Detail: tashkilotchi qarori — tasdiq `is_excused=true`, rad `false`
  /// (sabab saqlanadi, xodim qayta yoza olmaydi).
  Future<void> _onExcuseDecided(
    MeetingDetailExcuseDecided event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(excuseBusyId: event.attendanceId));
    try {
      final updated = await _updateAttendance(
        UpdateMeetingAttendanceParams(
          id: event.attendanceId,
          update: MeetingAttendanceUpdate(isExcused: event.approved),
        ),
      );
      emit(
        state.copyWith(
          excuseBusyId: 0,
          attendanceRows: [
            for (final row in state.attendanceRows)
              row.id == updated.id ? updated : row,
          ],
          rejectedExcuseIds: event.approved
              ? state.rejectedExcuseIds
              : {...state.rejectedExcuseIds, event.attendanceId},
        ),
      );
    } on Failure catch (_) {
      emit(state.copyWith(excuseBusyId: 0, excuseActionFailed: true));
    }
  }

  Future<void> _onCloseWithAttendance(
    MeetingCloseWithAttendanceSubmitted event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(closeStatus: MeetingCreateSubmitStatus.submitting));
    try {
      final rows = await _getAttendance(event.meetingId);
      for (final row in rows) {
        final userId = row.userId;
        if (userId == null) continue;
        final attended = event.attendedUserIds.contains(userId);
        // Faqat o'zgargan yozuvlar PATCH qilinadi.
        if (row.isAttended != attended) {
          await _updateAttendance(
            UpdateMeetingAttendanceParams(
              id: row.id,
              update: MeetingAttendanceUpdate(isAttended: attended),
            ),
          );
        }
      }
      await _closeMeeting(event.meetingId);
      emit(state.copyWith(closeStatus: MeetingCreateSubmitStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          closeStatus: MeetingCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }

  Future<void> _onUpdateSubmitted(
    MeetingUpdateSubmitted event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.submitting));
    try {
      final meeting = await _updateMeeting(
        UpdateMeetingParams(id: event.id, form: event.form),
      );
      if (event.closeAfterUpdate) await _closeMeeting(event.id);
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.success,
          submittedMeeting: meeting,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }
}
