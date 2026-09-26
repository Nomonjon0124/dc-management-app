import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/entities/meeting_attendance_update.dart';
import '../../domain/usecases/get_meeting_attendance_usecase.dart';
import '../../domain/usecases/get_meeting_usecase.dart';
import '../../domain/usecases/submit_absence_reason_usecase.dart';
import '../../domain/usecases/update_meeting_attendance_usecase.dart';

part 'meeting_reason_event.dart';
part 'meeting_reason_state.dart';

/// "Yig‘ilishga qatnashmadingiz" ekrani bloci — yig‘ilish sarlavhasi + sanasini
/// va qatnashuv yozuvlarini (`meeting-attendance`) yuklaydi.
///
/// Ikki rejim: oddiy qatnashchi o‘z yozuviga qatnashmaslik sababini PATCH
/// qiladi; tashkilotchi esa qatnashmaganlar sabablari ro‘yxatini ko‘rib,
/// ularni `is_excused=true` bilan tasdiqlaydi.
class MeetingReasonBloc extends Bloc<MeetingReasonEvent, MeetingReasonState> {
  MeetingReasonBloc({
    required GetMeetingUseCase getMeeting,
    required GetMeetingAttendanceUseCase getAttendance,
    required SubmitAbsenceReasonUseCase submitReason,
    required UpdateMeetingAttendanceUseCase updateAttendance,
    required StorageService storage,
  }) : _getMeeting = getMeeting,
       _getAttendance = getAttendance,
       _submitReason = submitReason,
       _updateAttendance = updateAttendance,
       _storage = storage,
       super(const MeetingReasonState()) {
    on<MeetingReasonLoaded>(_onLoaded);
    on<MeetingReasonSubmitted>(_onSubmitted);
    on<MeetingExcuseDecided>(_onExcuseDecided);
  }

  final GetMeetingUseCase _getMeeting;
  final GetMeetingAttendanceUseCase _getAttendance;
  final SubmitAbsenceReasonUseCase _submitReason;
  final UpdateMeetingAttendanceUseCase _updateAttendance;
  final StorageService _storage;

  /// Keshlangan login javobidagi (`cached_user`) joriy foydalanuvchi id'si.
  int? _currentUserId() {
    final raw = _storage.getString(StorageKeys.cachedUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map) return (map['id'] as num?)?.toInt();
    } on Object {
      // Buzuq kesh — rejim aniqlanmaydi, oddiy qatnashchi deb qaraladi.
    }
    return null;
  }

  Future<void> _onLoaded(
    MeetingReasonLoaded event,
    Emitter<MeetingReasonState> emit,
  ) async {
    emit(state.copyWith(loadStatus: MeetingReasonLoad.loading));
    try {
      final userId = _currentUserId();
      final attendance = await _getAttendance(event.meetingId);

      // Sana + tashkilotchi uchun yig‘ilishning o‘zi (best-effort).
      DateTime? startDate;
      int? organizerId;
      var title = '';
      try {
        final meeting = await _getMeeting(event.meetingId);
        startDate = meeting.startDate;
        organizerId = meeting.organizerId;
        if (meeting.title.isNotEmpty) title = meeting.title;
      } on Failure {
        // e'tiborsiz — attendance’dan sarlavha yetarli.
      }

      final isOrganizer = organizerId != null && organizerId == userId;

      // Joriy foydalanuvchining yozuvi: avval user_info.id bo‘yicha aniq
      // moslik, bo‘lmasa eski heuristika (qatnashmagan birinchi yozuv).
      MeetingAttendance? mine;
      for (final a in attendance) {
        if (userId != null && a.userId == userId) {
          mine = a;
          break;
        }
      }
      if (mine == null && userId == null) {
        for (final a in attendance) {
          if (!a.isAttended) {
            mine = a;
            break;
          }
        }
        mine ??= attendance.isNotEmpty ? attendance.first : null;
      }

      if (title.isEmpty) {
        title = attendance.isNotEmpty ? attendance.first.meetingTitle : '';
      }

      emit(
        state.copyWith(
          loadStatus: MeetingReasonLoad.success,
          title: title,
          startDate: startDate,
          attendanceId: mine?.id,
          myAttendance: mine,
          isOrganizer: isOrganizer,
          // Tashkilotchi ro'yxati: qatnashmaganlar va 5 daqiqadan ko'p
          // kechikkanlar backend qoidalariga ko'ra ko'rib chiqiladi.
          rows: isOrganizer
              ? [
                  for (final a in attendance)
                    if (!a.isAttended || a.lateMinutes > 5) a,
                ]
              : const [],
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loadStatus: MeetingReasonLoad.failure, failure: f));
    }
  }

  Future<void> _onSubmitted(
    MeetingReasonSubmitted event,
    Emitter<MeetingReasonState> emit,
  ) async {
    final text = event.reason.trim();
    if (text.isEmpty) return;
    final attendanceId = state.attendanceId;
    if (attendanceId == null) {
      emit(
        state.copyWith(
          submitStatus: MeetingReasonSubmit.failure,
          failure: const ServerFailure(),
        ),
      );
      return;
    }
    emit(state.copyWith(submitStatus: MeetingReasonSubmit.loading));
    try {
      await _submitReason(
        SubmitAbsenceReasonParams(attendanceId: attendanceId, reason: text),
      );
      emit(state.copyWith(submitStatus: MeetingReasonSubmit.success));
    } on Failure catch (f) {
      emit(
        state.copyWith(submitStatus: MeetingReasonSubmit.failure, failure: f),
      );
    }
  }

  /// Tashkilotchi qaror qiladi: tasdiq — `is_excused=true`; rad — `false`
  /// (sabab saqlanadi, foydalanuvchi qayta yoza olmaydi).
  Future<void> _onExcuseDecided(
    MeetingExcuseDecided event,
    Emitter<MeetingReasonState> emit,
  ) async {
    emit(state.copyWith(approvingId: event.attendanceId));
    try {
      final updated = await _updateAttendance(
        UpdateMeetingAttendanceParams(
          id: event.attendanceId,
          update: MeetingAttendanceUpdate(isExcused: event.approved),
        ),
      );
      emit(
        state.copyWith(
          approvingId: 0,
          rows: [
            for (final row in state.rows) row.id == updated.id ? updated : row,
          ],
          rejectedIds: event.approved
              ? state.rejectedIds
              : {...state.rejectedIds, event.attendanceId},
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(approvingId: 0, failure: f, approveFailed: true));
    }
  }
}
