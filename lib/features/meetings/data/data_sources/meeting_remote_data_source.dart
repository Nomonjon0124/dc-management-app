import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/meeting_attendance_filter.dart';
import '../../domain/entities/meeting_attendance_update.dart';
import '../../domain/entities/meeting_filter.dart';
import '../../domain/entities/meeting_form.dart';
import '../models/meeting_attendance_model.dart';
import '../models/meeting_model.dart';

/// Yig'ilishlar + qatnashuv backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class MeetingRemoteDataSource {
  Future<List<MeetingModel>> getMeetings({
    MeetingFilter filter = MeetingFilter.empty,
  });

  Future<MeetingModel> createMeeting(MeetingForm form);

  Future<MeetingModel> getMeeting(int id);

  Future<MeetingModel> updateMeeting(int id, MeetingForm form);

  Future<MeetingModel> patchMeeting(int id, MeetingPatch patch);

  Future<void> deleteMeeting(int id);

  Future<MeetingModel> closeMeeting(int id);

  Future<List<MeetingModel>> getTrashedMeetings();

  Future<void> hardDeleteMeeting(int id);

  Future<MeetingModel> restoreMeeting(int id);

  /// Yig'ilishdagi qatnashuv yozuvlari (`GET /meeting-attendance/?meeting=`).
  Future<List<MeetingAttendanceModel>> getMeetingAttendance(int meetingId);

  Future<List<MeetingAttendanceModel>> listMeetingAttendance({
    MeetingAttendanceFilter filter = MeetingAttendanceFilter.empty,
  });

  Future<MeetingAttendanceModel> getMeetingAttendanceById(int id);

  Future<MeetingAttendanceModel> updateMeetingAttendance(
    int attendanceId,
    MeetingAttendanceUpdate update,
  );

  /// Qatnashmaslik sababini yuboradi
  /// (`PATCH /meeting-attendance/{attendanceId}/` -> `{absence_reason}`).
  Future<MeetingAttendanceModel> submitAbsenceReason(
    int attendanceId,
    String reason,
  );
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  const MeetingRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<MeetingModel>> getMeetings({
    MeetingFilter filter = MeetingFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.meetings,
        queryParameters: _meetingFilterParams(filter),
      );
      return _meetingList(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> createMeeting(MeetingForm form) async {
    try {
      final response = await _client.post(
        ApiConstants.meetings,
        data: _meetingFormData(form),
      );
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> getMeeting(int id) async {
    try {
      final response = await _client.get(ApiConstants.meetingById(id));
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> updateMeeting(int id, MeetingForm form) async {
    try {
      final response = await _client.put(
        ApiConstants.meetingById(id),
        data: _meetingFormData(form),
      );
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> patchMeeting(int id, MeetingPatch patch) async {
    try {
      final response = await _client.patch(
        ApiConstants.meetingById(id),
        data: _meetingPatchData(patch),
      );
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> deleteMeeting(int id) async {
    try {
      await _client.delete(ApiConstants.meetingById(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> closeMeeting(int id) async {
    try {
      final response = await _client.post(ApiConstants.meetingClose(id));
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<MeetingModel>> getTrashedMeetings() async {
    try {
      final response = await _client.get(ApiConstants.meetingsTrash);
      return _meetingList(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> hardDeleteMeeting(int id) async {
    try {
      await _client.delete(ApiConstants.meetingHardDelete(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> restoreMeeting(int id) async {
    try {
      final response = await _client.post(ApiConstants.meetingRestore(id));
      return _meeting(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<MeetingAttendanceModel>> getMeetingAttendance(int meetingId) {
    return listMeetingAttendance(
      filter: MeetingAttendanceFilter(meetingId: meetingId),
    );
  }

  @override
  Future<List<MeetingAttendanceModel>> listMeetingAttendance({
    MeetingAttendanceFilter filter = MeetingAttendanceFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.meetingAttendance,
        queryParameters: _attendanceFilterParams(filter),
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map(
            (e) => MeetingAttendanceModel.fromJson(e.cast<String, dynamic>()),
          )
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingAttendanceModel> getMeetingAttendanceById(int id) async {
    try {
      final response = await _client.get(
        ApiConstants.meetingAttendanceById(id),
      );
      return MeetingAttendanceModel.fromJson(
        ResponseMapper.asMap(response.data),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingAttendanceModel> updateMeetingAttendance(
    int attendanceId,
    MeetingAttendanceUpdate update,
  ) async {
    try {
      final response = await _client.patch(
        ApiConstants.meetingAttendanceById(attendanceId),
        data: _attendanceUpdateData(update),
      );
      return MeetingAttendanceModel.fromJson(
        ResponseMapper.asMap(response.data),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingAttendanceModel> submitAbsenceReason(
    int attendanceId,
    String reason,
  ) {
    return updateMeetingAttendance(
      attendanceId,
      MeetingAttendanceUpdate(absenceReason: reason),
    );
  }

  MeetingModel _meeting(dynamic data) {
    return MeetingModel.fromJson(ResponseMapper.asMap(data));
  }

  List<MeetingModel> _meetingList(dynamic data) {
    final items = ResponseMapper.asList(data)
        .whereType<Map>()
        .map((e) => MeetingModel.fromJson(e.cast<String, dynamic>()))
        .toList();
    if (items.isNotEmpty) return items;

    final body = ResponseMapper.asMap(data);
    if (body['id'] != null) return [MeetingModel.fromJson(body)];
    return const [];
  }

  Map<String, dynamic> _meetingFilterParams(MeetingFilter filter) => {
    if (filter.isCompleted != null) 'is_completed': filter.isCompleted,
    if (filter.ordering?.trim().isNotEmpty ?? false)
      'ordering': filter.ordering!.trim(),
    if (filter.organizerId != null) 'organizer': filter.organizerId,
    if (filter.page != null) 'page': filter.page,
    if (filter.projectId != null) 'project': filter.projectId,
    if (filter.search?.trim().isNotEmpty ?? false)
      'search': filter.search!.trim(),
    if (filter.uid?.trim().isNotEmpty ?? false) 'uid': filter.uid!.trim(),
    if (filter.startDateGte != null)
      'start_date_gte': _dateOnly(filter.startDateGte!),
    if (filter.startDateLte != null)
      'start_date_lte': _dateOnly(filter.startDateLte!),
  };

  Map<String, dynamic> _attendanceFilterParams(
    MeetingAttendanceFilter filter,
  ) => {
    if (filter.isAttended != null) 'is_attended': filter.isAttended,
    if (filter.meetingId != null) 'meeting': filter.meetingId,
    if (filter.page != null) 'page': filter.page,
    if (filter.userId != null) 'user': filter.userId,
  };

  Map<String, dynamic> _meetingFormData(MeetingForm form) => {
    'project': form.project,
    'title': form.title,
    'description': form.description,
    if (form.penaltyPercentage != null)
      'penalty_percentage': form.penaltyPercentage,
    'start_time': form.startTime.toIso8601String(),
    'duration_minutes': form.durationMinutes,
    'participants': form.participants,
    'requires_approval': form.requiresApproval,
  };

  Map<String, dynamic> _meetingPatchData(MeetingPatch patch) => {
    if (patch.project != null) 'project': patch.project,
    if (patch.title != null) 'title': patch.title,
    if (patch.description != null) 'description': patch.description,
    if (patch.link != null) 'link': patch.link,
    if (patch.penaltyPercentage != null)
      'penalty_percentage': patch.penaltyPercentage,
    if (patch.startTime != null)
      'start_time': patch.startTime!.toIso8601String(),
    if (patch.durationMinutes != null)
      'duration_minutes': patch.durationMinutes,
    if (patch.participants != null) 'participants': patch.participants,
    if (patch.requiresApproval != null)
      'requires_approval': patch.requiresApproval,
  };

  Map<String, dynamic> _attendanceUpdateData(
    MeetingAttendanceUpdate update,
  ) => {
    if (update.isAttended != null) 'is_attended': update.isAttended,
    if (update.isExcused != null) 'is_excused': update.isExcused,
    if (update.absenceReason != null) 'absence_reason': update.absenceReason,
  };

  String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
}
