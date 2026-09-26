import 'dart:async';

import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_attendance.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_attendance_filter.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_attendance_update.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_filter.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_form.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_room.dart';
import 'package:dc_management_app/features/meetings/domain/repository/meeting_repository.dart';
import 'package:dc_management_app/features/meetings/domain/repository/meeting_room_repository.dart';
import 'package:dc_management_app/features/meetings/domain/usecases/close_meeting_usecase.dart';
import 'package:dc_management_app/features/meetings/domain/usecases/get_meeting_usecase.dart';
import 'package:dc_management_app/features/meetings/data/services/livekit_media_service.dart';
import 'package:dc_management_app/features/meetings/presentation/bloc/meeting_room_bloc.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/call/meeting_call_control_bar.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/call/meeting_call_participant_tile.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/call/meeting_call_stage.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_room_page.dart';
import 'package:dc_management_app/injection_container.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeMeetingRoomRepository roomRepository;

  setUp(() async {
    await getIt.reset();
    roomRepository = _FakeMeetingRoomRepository();
    final meetingRepository = _MeetingRepositoryStub(_meeting);
    getIt
      ..registerFactory<MeetingRoomBloc>(
        () => MeetingRoomBloc(
          repository: roomRepository,
          closeMeeting: CloseMeetingUseCase(meetingRepository),
          getMeeting: GetMeetingUseCase(meetingRepository),
        ),
      )
      // The fake room intentionally has no video track, so avatar fallback is
      // exercised in this test.
      ..registerLazySingleton<LiveKitMediaService>(LiveKitMediaService.new);
  });

  tearDown(() async {
    await roomRepository.dispose();
    await getIt.reset();
  });

  testWidgets('production room renders the Figma controls after LiveKit join', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Design meeting'), findsOneWidget);
    expect(find.byType(MeetingCallControlBar), findsNothing);

    await tester.ensureVisible(find.text('Qo‘shilish'));
    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();

    expect(find.text('Design meeting'), findsOneWidget);
    expect(find.byType(MeetingCallControlBar), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(
      tester.getSize(find.byType(MeetingCallStage)).height,
      greaterThan(0),
    );
  });

  testWidgets('production room renders the approval waiting state', (
    tester,
  ) async {
    roomRepository.requiresApproval = true;
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Qo‘shilish'));
    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tashkilotchi ruxsat bergach avtomatik kirasiz.'),
      findsOneWidget,
    );
    expect(find.byType(MeetingCallControlBar), findsNothing);
  });

  testWidgets('chat sheet keeps the production meeting bloc scope', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Qo‘shilish'));
    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.bySemanticsLabel('Yana'));
    await tester.tap(find.bySemanticsLabel('Yana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Hali xabar yo‘q'), findsOneWidget);
  });

  testWidgets('web-style reactions animate and expire from the meeting stage', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Qo‘shilish'));
    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();

    roomRepository.emit(
      const MeetingRealtimeMessage(type: 'reaction_received', reaction: '🎉'),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('🎉'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('🎉'), findsNothing);
  });

  testWidgets('compact participant label fits a local mini-card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          theme: ThemeData(extensions: [AppColors.light()]),
          home: const SizedBox(
            width: 96,
            height: 128,
            child: MeetingCallParticipantTile(
              name: 'A very long participant name',
              compactLabel: true,
              microphoneOn: true,
              handRaised: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(600, 960),
    Size(844, 390),
  ]) {
    testWidgets('production control bar fits at ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_controlBarApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final leaveButton = find.bySemanticsLabel('Leave');
      expect(leaveButton, findsOneWidget);
      expect(tester.getRect(leaveButton).right, lessThanOrEqualTo(size.width));
    });
  }
}

Widget _app() {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      theme: ThemeData(extensions: [AppColors.light()]),
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MeetingRoomPage(meetingId: _meeting.id, initialMeeting: _meeting),
    ),
  );
}

Widget _controlBarApp() {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      theme: ThemeData(extensions: [AppColors.light()]),
      home: const Scaffold(
        body: SafeArea(
          child: MeetingCallControlBar(
            microphoneOn: true,
            cameraOn: true,
            handRaised: false,
            onMicrophone: _noop,
            onCamera: _noop,
            onHand: _noop,
            onMore: _noop,
            onLeave: _noop,
            microphoneLabel: 'Microphone',
            cameraLabel: 'Camera',
            handLabel: 'Hand',
            moreLabel: 'More',
            leaveLabel: 'Leave',
          ),
        ),
      ),
    ),
  );
}

void _noop() {}

final _meeting = Meeting(
  id: 33,
  title: 'Design meeting',
  uid: 'MT-0033',
  projectName: 'Project',
  startDate: DateTime(2026, 9, 22, 15, 40),
  organizerName: 'Organizer',
  organizerRole: 'Manager',
  participantName: 'Participant',
  participantPosition: 'Employee',
  isCompleted: false,
  reason: '',
  attended: null,
);

class _FakeMeetingRoomRepository implements MeetingRoomRepository {
  final _events = StreamController<MeetingRealtimeMessage>.broadcast();
  final _mediaEvents = StreamController<MeetingMediaEvent>.broadcast();
  bool requiresApproval = false;

  @override
  Stream<MeetingRealtimeMessage> get events => _events.stream;

  @override
  Stream<MeetingMediaEvent> get mediaEvents => _mediaEvents.stream;

  @override
  Future<void> open(int meetingId) async {
    _events.add(
      MeetingRealtimeMessage(
        type: 'meeting_state',
        title: 'Design meeting',
        requiresApproval: requiresApproval,
        organizerJoined: true,
        isHost: !requiresApproval,
      ),
    );
  }

  @override
  Future<void> requestToJoin() async {}

  @override
  Future<void> approve(int userId) async {}

  @override
  Future<void> reject(int userId) async {}

  @override
  Future<void> requestToken({String? deviceId, String? deviceName}) async {
    _events.add(
      const MeetingRealtimeMessage(
        type: 'token_response',
        token: MeetingRoomToken(
          serverUrl: 'wss://livekit.example.com',
          roomName: 'room-33',
          token: 'token',
        ),
      ),
    );
  }

  @override
  Future<void> connectMedia(MeetingRoomToken token) async {
    _mediaEvents.add(
      const MeetingMediaEvent(
        type: MeetingMediaEventType.connected,
        participants: [
          MeetingRoomParticipant(
            identity: 'local',
            name: 'You',
            isLocal: true,
            isSpeaking: false,
            microphoneEnabled: false,
            cameraEnabled: false,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  Future<void> setHandRaised(bool raised) async {}

  @override
  Future<void> sendChatMessage(String message) async {}

  @override
  Future<void> sendReaction(String reaction) async {}

  @override
  Future<void> moderateTrack({
    required String targetIdentity,
    required String trackSource,
  }) async {}

  @override
  Future<void> requestTrackUnmute({
    required String targetIdentity,
    required String trackSource,
  }) async {}

  @override
  Future<void> respondTrackUnmute({
    required String requestId,
    required String trackSource,
    required bool accept,
  }) async {}

  @override
  Future<void> setScreenShareEnabled(bool enabled) async {}

  @override
  Future<void> setAudioInputDevice(String deviceId) async {}

  @override
  Future<void> setAudioOutputDevice(String deviceId) async {}

  @override
  Future<void> setVideoInputDevice(String deviceId) async {}

  @override
  Future<void> setCameraPosition(MeetingCameraPosition position) async {}

  @override
  Future<void> close() async {}

  void emit(MeetingRealtimeMessage message) => _events.add(message);

  Future<void> dispose() async {
    await _events.close();
    await _mediaEvents.close();
  }
}

class _MeetingRepositoryStub implements MeetingRepository {
  const _MeetingRepositoryStub(this.meeting);

  final Meeting meeting;

  @override
  Future<Meeting> getMeeting(int id) async => meeting;

  @override
  Future<Meeting> closeMeeting(int id) async => meeting;

  @override
  Future<List<Meeting>> getMeetings({
    MeetingFilter filter = MeetingFilter.empty,
  }) async => [meeting];

  @override
  Future<Meeting> createMeeting(MeetingForm form) => _unsupported();

  @override
  Future<Meeting> updateMeeting(int id, MeetingForm form) => _unsupported();

  @override
  Future<Meeting> patchMeeting(int id, MeetingPatch patch) => _unsupported();

  @override
  Future<void> deleteMeeting(int id) => _unsupported();

  @override
  Future<List<Meeting>> getTrashedMeetings() => _unsupported();

  @override
  Future<void> hardDeleteMeeting(int id) => _unsupported();

  @override
  Future<Meeting> restoreMeeting(int id) => _unsupported();

  @override
  Future<List<MeetingAttendance>> getMeetingAttendance(int meetingId) =>
      _unsupported();

  @override
  Future<List<MeetingAttendance>> listMeetingAttendance({
    MeetingAttendanceFilter filter = MeetingAttendanceFilter.empty,
  }) => _unsupported();

  @override
  Future<MeetingAttendance> getMeetingAttendanceById(int id) => _unsupported();

  @override
  Future<MeetingAttendance> updateMeetingAttendance(
    int attendanceId,
    MeetingAttendanceUpdate update,
  ) => _unsupported();

  @override
  Future<MeetingAttendance> submitAbsenceReason(
    int attendanceId,
    String reason,
  ) => _unsupported();

  Future<T> _unsupported<T>() =>
      Future<T>.error(UnimplementedError('Not used by this test'));
}
