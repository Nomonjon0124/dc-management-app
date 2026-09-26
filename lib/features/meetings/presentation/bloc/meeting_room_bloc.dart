import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/meeting_room.dart';
import '../../domain/repository/meeting_room_repository.dart';
import '../../domain/usecases/close_meeting_usecase.dart';
import '../../domain/usecases/get_meeting_usecase.dart';
import 'meeting_room_event.dart';
import 'meeting_room_state.dart';

class MeetingRoomBloc extends Bloc<MeetingRoomEvent, MeetingRoomState> {
  MeetingRoomBloc({
    required MeetingRoomRepository repository,
    required CloseMeetingUseCase closeMeeting,
    required GetMeetingUseCase getMeeting,
  }) : _repository = repository,
       _closeMeeting = closeMeeting,
       _getMeeting = getMeeting,
       super(const MeetingRoomState()) {
    on<MeetingRoomStarted>(_onStarted);
    on<MeetingRoomJoinRequested>(_onJoinRequested);
    on<MeetingRoomJoinCancelled>(_onJoinCancelled);
    on<MeetingRoomUserApproved>(_onUserApproved);
    on<MeetingRoomUserRejected>(_onUserRejected);
    on<MeetingRoomLeaveRequested>(_onLeaveRequested);
    on<MeetingRoomEndRequested>(_onEndRequested);
    on<MeetingRoomRetryRequested>(_onRetryRequested);
    on<MeetingRoomMicrophoneToggled>(_onMicrophoneToggled);
    on<MeetingRoomCameraToggled>(_onCameraToggled);
    on<MeetingRoomHandToggled>(_onHandToggled);
    on<MeetingRoomChatMessageSent>(_onChatMessageSent);
    on<MeetingRoomReactionSent>(_onReactionSent);
    on<MeetingRoomReactionExpired>(_onReactionExpired);
    on<MeetingRoomParticipantMuted>(_onParticipantMuted);
    on<MeetingRoomUnmuteRequested>(_onUnmuteRequested);
    on<MeetingRoomUnmuteResponseSent>(_onUnmuteResponseSent);
    on<MeetingRoomScreenShareToggled>(_onScreenShareToggled);
    on<MeetingRoomAudioInputSelected>(_onAudioInputSelected);
    on<MeetingRoomAudioOutputSelected>(_onAudioOutputSelected);
    on<MeetingRoomVideoInputSelected>(_onVideoInputSelected);
    on<MeetingRoomCameraPositionSelected>(_onCameraPositionSelected);
    _realtimeSubscription = _repository.events.listen(
      (message) => add(_RealtimeMessageReceived(message)),
    );
    _mediaSubscription = _repository.mediaEvents.listen(
      (event) => add(_MediaEventReceived(event)),
    );
    on<_RealtimeMessageReceived>(_onRealtimeMessage);
    on<_MediaEventReceived>(_onMediaEvent);
  }

  final MeetingRoomRepository _repository;
  final CloseMeetingUseCase _closeMeeting;
  final GetMeetingUseCase _getMeeting;
  StreamSubscription<MeetingRealtimeMessage>? _realtimeSubscription;
  StreamSubscription<MeetingMediaEvent>? _mediaSubscription;
  bool _joinRequested = false;
  bool _admissionRequested = false;
  bool _tokenRequested = false;
  bool _mediaConnectRequested = false;
  bool _endRequested = false;

  Future<void> _onStarted(
    MeetingRoomStarted event,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (state.meetingId == event.meetingId) return;
    final initial = event.initialMeeting;
    emit(
      state.copyWith(
        meetingId: event.meetingId,
        meeting: initial,
        title: initial?.title ?? '',
        clearError: true,
      ),
    );
    if (initial != null) return;
    try {
      final meeting = await _getMeeting(event.meetingId);
      if (state.meetingId == event.meetingId) {
        emit(state.copyWith(meeting: meeting, title: meeting.title));
      }
    } on Object {
      // The realtime `meeting_state` event remains the source of truth for
      // room admission. The room can still open if the detail lookup fails.
    }
  }

  Future<void> _onJoinRequested(
    MeetingRoomJoinRequested event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final meetingId = state.meetingId;
    if (meetingId == null || _joinRequested) return;
    _joinRequested = true;
    _admissionRequested = false;
    _tokenRequested = false;
    _mediaConnectRequested = false;
    emit(
      state.copyWith(
        phase: MeetingRoomPhase.socketConnecting,
        clearError: true,
      ),
    );
    try {
      await _repository.open(meetingId);
    } on Object catch (error) {
      _joinRequested = false;
      emit(
        state.copyWith(
          phase: MeetingRoomPhase.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onJoinCancelled(
    MeetingRoomJoinCancelled event,
    Emitter<MeetingRoomState> emit,
  ) async {
    _joinRequested = false;
    _admissionRequested = false;
    _tokenRequested = false;
    _mediaConnectRequested = false;
    await _repository.close();
    emit(state.copyWith(phase: MeetingRoomPhase.prejoin, clearError: true));
  }

  Future<void> _onUserApproved(
    MeetingRoomUserApproved event,
    Emitter<MeetingRoomState> emit,
  ) => _sendHostDecision(event.userId, approve: true, emit: emit);

  Future<void> _onUserRejected(
    MeetingRoomUserRejected event,
    Emitter<MeetingRoomState> emit,
  ) => _sendHostDecision(event.userId, approve: false, emit: emit);

  Future<void> _sendHostDecision(
    int userId, {
    required bool approve,
    required Emitter<MeetingRoomState> emit,
  }) async {
    try {
      if (approve) {
        await _repository.approve(userId);
      } else {
        await _repository.reject(userId);
      }
      emit(
        state.copyWith(
          pendingRequests: [
            for (final request in state.pendingRequests)
              if (request.userId != userId) request,
          ],
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onLeaveRequested(
    MeetingRoomLeaveRequested event,
    Emitter<MeetingRoomState> emit,
  ) async {
    _joinRequested = false;
    _admissionRequested = false;
    _tokenRequested = false;
    _mediaConnectRequested = false;
    await _repository.close();
    emit(state.copyWith(phase: MeetingRoomPhase.left, clearError: true));
  }

  Future<void> _onEndRequested(
    MeetingRoomEndRequested event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final meetingId = state.meetingId;
    if (meetingId == null || !state.isHost || _endRequested) return;
    _endRequested = true;
    try {
      await _closeMeeting(meetingId);
      await _repository.close();
      emit(state.copyWith(phase: MeetingRoomPhase.ended, clearError: true));
    } on Object catch (error) {
      _endRequested = false;
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onRetryRequested(
    MeetingRoomRetryRequested event,
    Emitter<MeetingRoomState> emit,
  ) async {
    _joinRequested = false;
    _admissionRequested = false;
    _tokenRequested = false;
    _mediaConnectRequested = false;
    _endRequested = false;
    emit(state.copyWith(phase: MeetingRoomPhase.prejoin, clearError: true));
    add(const MeetingRoomJoinRequested());
  }

  Future<void> _onMicrophoneToggled(
    MeetingRoomMicrophoneToggled event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final enabled = !state.microphoneEnabled;
    if (state.phase == MeetingRoomPhase.prejoin) {
      emit(state.copyWith(microphoneEnabled: enabled));
      return;
    }
    try {
      await _repository.setMicrophoneEnabled(enabled);
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onCameraToggled(
    MeetingRoomCameraToggled event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final enabled = !state.cameraEnabled;
    if (state.phase == MeetingRoomPhase.prejoin) {
      emit(state.copyWith(cameraEnabled: enabled));
      return;
    }
    try {
      await _repository.setCameraEnabled(enabled);
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onHandToggled(
    MeetingRoomHandToggled event,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (state.phase != MeetingRoomPhase.connected &&
        state.phase != MeetingRoomPhase.reconnecting) {
      return;
    }
    final raised = !state.handRaised;
    try {
      await _repository.setHandRaised(raised);
      emit(
        state.copyWith(
          handRaised: raised,
          participants: _withLocalHand(state.participants, raised),
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onChatMessageSent(
    MeetingRoomChatMessageSent event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final message = event.message.trim();
    if (message.isEmpty) return;
    try {
      await _repository.sendChatMessage(message);
      final local = _localParticipant(state.participants);
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            MeetingRoomDataMessage(
              type: 'chat',
              senderIdentity: local?.identity ?? 'local',
              senderName: local?.name ?? 'Siz',
              text: message,
              sentAt: DateTime.now(),
            ),
          ],
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onReactionSent(
    MeetingRoomReactionSent event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.sendReaction(event.reaction);
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void _onReactionExpired(
    MeetingRoomReactionExpired event,
    Emitter<MeetingRoomState> emit,
  ) {
    emit(
      state.copyWith(
        reactions: [
          for (final reaction in state.reactions)
            if (reaction.id != event.reactionId) reaction,
        ],
      ),
    );
  }

  Future<void> _onParticipantMuted(
    MeetingRoomParticipantMuted event,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (!state.isHost || state.phase != MeetingRoomPhase.connected) return;
    try {
      await _repository.moderateTrack(
        targetIdentity: event.targetIdentity,
        trackSource: event.trackSource,
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onUnmuteRequested(
    MeetingRoomUnmuteRequested event,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (!state.isHost || state.phase != MeetingRoomPhase.connected) return;
    try {
      await _repository.requestTrackUnmute(
        targetIdentity: event.targetIdentity,
        trackSource: event.trackSource,
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onUnmuteResponseSent(
    MeetingRoomUnmuteResponseSent event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.respondTrackUnmute(
        requestId: event.requestId,
        trackSource: event.trackSource,
        accept: event.accept,
      );
      emit(
        state.copyWith(
          pendingUnmuteRequests: [
            for (final request in state.pendingUnmuteRequests)
              if (request.requestId != event.requestId) request,
          ],
        ),
      );
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onScreenShareToggled(
    MeetingRoomScreenShareToggled event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.setScreenShareEnabled(event.enabled);
      emit(state.copyWith(screenSharing: event.enabled, clearError: true));
    } on Object {
      emit(
        state.copyWith(
          screenSharing: false,
          error: MeetingRoomError.screenShareFailed,
        ),
      );
    }
  }

  Future<void> _onAudioInputSelected(
    MeetingRoomAudioInputSelected event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.setAudioInputDevice(event.deviceId);
      emit(state.copyWith(selectedAudioInputId: event.deviceId));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onAudioOutputSelected(
    MeetingRoomAudioOutputSelected event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.setAudioOutputDevice(event.deviceId);
      emit(state.copyWith(selectedAudioOutputId: event.deviceId));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onVideoInputSelected(
    MeetingRoomVideoInputSelected event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.setVideoInputDevice(event.deviceId);
      emit(state.copyWith(selectedVideoInputId: event.deviceId));
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  Future<void> _onCameraPositionSelected(
    MeetingRoomCameraPositionSelected event,
    Emitter<MeetingRoomState> emit,
  ) async {
    try {
      await _repository.setCameraPosition(event.position);
    } on Object catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  List<MeetingRoomParticipant> _withLocalHand(
    List<MeetingRoomParticipant> participants,
    bool raised,
  ) => [
    for (final participant in participants)
      participant.isLocal
          ? MeetingRoomParticipant(
              identity: participant.identity,
              name: participant.name,
              isLocal: participant.isLocal,
              isSpeaking: participant.isSpeaking,
              microphoneEnabled: participant.microphoneEnabled,
              cameraEnabled: participant.cameraEnabled,
              audioTrackSid: participant.audioTrackSid,
              videoTrackSid: participant.videoTrackSid,
              screenShareTrackSid: participant.screenShareTrackSid,
              handRaised: raised,
              screenSharing: participant.screenSharing,
              userId: participant.userId,
              deviceId: participant.deviceId,
              deviceName: participant.deviceName,
              sessionIdentities: participant.sessionIdentities,
            )
          : participant,
  ];

  List<MeetingRoomParticipant> _withRemoteHand(
    List<MeetingRoomParticipant> participants,
    String identity,
    bool raised,
  ) => [
    for (final participant in participants)
      participant.identity == identity
          ? MeetingRoomParticipant(
              identity: participant.identity,
              name: participant.name,
              isLocal: participant.isLocal,
              isSpeaking: participant.isSpeaking,
              microphoneEnabled: participant.microphoneEnabled,
              cameraEnabled: participant.cameraEnabled,
              audioTrackSid: participant.audioTrackSid,
              videoTrackSid: participant.videoTrackSid,
              screenShareTrackSid: participant.screenShareTrackSid,
              handRaised: raised,
              screenSharing: participant.screenSharing,
              userId: participant.userId,
              deviceId: participant.deviceId,
              deviceName: participant.deviceName,
              sessionIdentities: participant.sessionIdentities,
            )
          : participant,
  ];

  List<MeetingRoomParticipant> _withUserHand(
    List<MeetingRoomParticipant> participants,
    int userId,
    bool raised,
  ) => [
    for (final participant in participants)
      participant.userId == userId
          ? MeetingRoomParticipant(
              identity: participant.identity,
              name: participant.name,
              isLocal: participant.isLocal,
              isSpeaking: participant.isSpeaking,
              microphoneEnabled: participant.microphoneEnabled,
              cameraEnabled: participant.cameraEnabled,
              audioTrackSid: participant.audioTrackSid,
              videoTrackSid: participant.videoTrackSid,
              screenShareTrackSid: participant.screenShareTrackSid,
              handRaised: raised,
              screenSharing: participant.screenSharing,
              userId: participant.userId,
              deviceId: participant.deviceId,
              deviceName: participant.deviceName,
              sessionIdentities: participant.sessionIdentities,
            )
          : participant,
  ];

  List<MeetingRoomParticipant> _withTrackMuted(
    List<MeetingRoomParticipant> participants, {
    required String targetIdentity,
    required String trackSource,
    required bool muted,
  }) => [
    for (final participant in participants)
      participant.identity == targetIdentity ||
              participant.sessionIdentities.contains(targetIdentity)
          ? MeetingRoomParticipant(
              identity: participant.identity,
              name: participant.name,
              isLocal: participant.isLocal,
              isSpeaking: participant.isSpeaking,
              microphoneEnabled: trackSource == 'microphone'
                  ? !muted
                  : participant.microphoneEnabled,
              cameraEnabled: trackSource == 'camera'
                  ? !muted
                  : participant.cameraEnabled,
              audioTrackSid: participant.audioTrackSid,
              videoTrackSid: participant.videoTrackSid,
              screenShareTrackSid: participant.screenShareTrackSid,
              handRaised: participant.handRaised,
              screenSharing: participant.screenSharing,
              userId: participant.userId,
              deviceId: participant.deviceId,
              deviceName: participant.deviceName,
              sessionIdentities: participant.sessionIdentities,
            )
          : participant,
  ];

  bool _isLocalUser(int userId) => state.participants.any(
    (participant) => participant.isLocal && participant.userId == userId,
  );

  MeetingRoomParticipant? _localParticipant(
    List<MeetingRoomParticipant> participants,
  ) {
    for (final participant in participants) {
      if (participant.isLocal) return participant;
    }
    return null;
  }

  List<MeetingRoomParticipant> _preserveParticipantFlags(
    List<MeetingRoomParticipant> participants,
  ) {
    final previous = <String, MeetingRoomParticipant>{
      for (final participant in state.participants)
        participant.identity: participant,
    };
    return [
      for (final participant in participants)
        previous[participant.identity] == null
            ? participant
            : MeetingRoomParticipant(
                identity: participant.identity,
                name: participant.name,
                isLocal: participant.isLocal,
                isSpeaking: participant.isSpeaking,
                microphoneEnabled: participant.microphoneEnabled,
                cameraEnabled: participant.cameraEnabled,
                audioTrackSid: participant.audioTrackSid,
                videoTrackSid: participant.videoTrackSid,
                screenShareTrackSid: participant.screenShareTrackSid,
                handRaised: previous[participant.identity]!.handRaised,
                screenSharing: participant.screenSharing,
                userId: participant.userId,
                deviceId: participant.deviceId,
                deviceName: participant.deviceName,
                sessionIdentities: participant.sessionIdentities,
              ),
    ];
  }

  Future<void> _onRealtimeMessage(
    _RealtimeMessageReceived event,
    Emitter<MeetingRoomState> emit,
  ) async {
    final message = event.message;
    switch (message.type) {
      case 'meeting_state':
        final next = state.copyWith(
          title: message.title,
          requiresApproval: message.requiresApproval,
          organizerJoined: message.organizerJoined,
          isHost: message.isHost,
          isApproved: message.isApproved,
          clearError: true,
        );
        emit(next);
        await _continueAdmission(next, message.token, emit);
      case 'waiting_organizer':
        emit(state.copyWith(phase: MeetingRoomPhase.waitingOrganizer));
      case 'organizer_joined':
        final next = state.copyWith(organizerJoined: true);
        emit(next);
        await _continueAdmission(next, message.token, emit);
      case 'knock_response':
        if (message.status == 'approved') {
          final next = state.copyWith(isApproved: true);
          emit(next);
          await _continueAdmission(next, message.token, emit);
        } else if (message.status == 'rejected') {
          emit(
            state.copyWith(
              phase: MeetingRoomPhase.rejected,
              errorMessage: message.message,
            ),
          );
        }
      case 'knock_request':
        if (message.userId != null) {
          final exists = state.pendingRequests.any(
            (request) => request.userId == message.userId,
          );
          if (!exists) {
            emit(
              state.copyWith(
                pendingRequests: [
                  ...state.pendingRequests,
                  MeetingRoomJoinRequest(
                    userId: message.userId!,
                    username: message.username ?? 'Foydalanuvchi',
                    avatar: message.avatar,
                  ),
                ],
              ),
            );
          }
        }
      case 'token_response':
        if (message.token != null) {
          await _connectMedia(message.token!, emit);
        }
      case 'hand_raise_updated':
        if (message.userId != null && message.raised != null) {
          emit(
            state.copyWith(
              handRaised: _isLocalUser(message.userId!)
                  ? message.raised
                  : state.handRaised,
              participants: _withUserHand(
                state.participants,
                message.userId!,
                message.raised!,
              ),
            ),
          );
        }
      case 'reaction_received':
        if (message.reaction?.isNotEmpty == true) {
          final reaction = MeetingRoomDataMessage(
            type: 'reaction',
            id: _reactionId(),
            senderIdentity:
                message.targetIdentity ??
                message.userId?.toString() ??
                'participant',
            senderName: message.username ?? 'Foydalanuvchi',
            reaction: message.reaction,
            sentAt: message.raisedAt ?? DateTime.now(),
          );
          emit(
            state.copyWith(
              reactions: _appendReaction(state.reactions, reaction),
            ),
          );
        }
      case 'track_moderation_changed':
        if (message.targetIdentity != null && message.trackSource != null) {
          emit(
            state.copyWith(
              participants: _withTrackMuted(
                state.participants,
                targetIdentity: message.targetIdentity!,
                trackSource: message.trackSource!,
                muted: message.muted ?? true,
              ),
            ),
          );
        }
      case 'track_unmute_requested':
        if (message.requestId != null && message.trackSource != null) {
          final request = MeetingTrackUnmuteRequest(
            requestId: message.requestId!,
            trackSource: message.trackSource!,
            targetIdentity: message.targetIdentity,
            fromUserId: message.fromUserId,
            fromName: message.fromName,
            expiresAt: message.expiresAt,
          );
          if (!state.pendingUnmuteRequests.any(
            (item) => item.requestId == request.requestId,
          )) {
            emit(
              state.copyWith(
                pendingUnmuteRequests: [
                  ...state.pendingUnmuteRequests,
                  request,
                ],
              ),
            );
          }
        }
      case 'track_unmute_request_result':
        if (message.requestId != null) {
          emit(
            state.copyWith(
              pendingUnmuteRequests: [
                for (final request in state.pendingUnmuteRequests)
                  if (request.requestId != message.requestId) request,
              ],
            ),
          );
        }
      case 'meeting_ended':
        await _repository.close();
        emit(state.copyWith(phase: MeetingRoomPhase.ended));
      case 'error':
        final terminal =
            message.code == 4003 ||
            message.code == 4004 ||
            message.code == 401 ||
            message.code == 403 ||
            message.code == 404;
        if (terminal) await _repository.close();
        emit(
          state.copyWith(
            phase: MeetingRoomPhase.failure,
            errorMessage: message.message ?? 'Meetingga kirib bo‘lmadi',
          ),
        );
      case 'socket_error':
        emit(
          state.copyWith(
            phase: state.phase == MeetingRoomPhase.connected
                ? MeetingRoomPhase.reconnecting
                : MeetingRoomPhase.socketConnecting,
            errorMessage: message.message,
          ),
        );
    }
  }

  Future<void> _continueAdmission(
    MeetingRoomState next,
    MeetingRoomToken? token,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (token != null) {
      await _connectMedia(token, emit);
      return;
    }
    if (next.isHost || next.isApproved || !next.requiresApproval) {
      if (_tokenRequested || _mediaConnectRequested) return;
      _tokenRequested = true;
      emit(state.copyWith(phase: MeetingRoomPhase.joiningMedia));
      try {
        await _repository.requestToken();
      } on Object catch (error) {
        _tokenRequested = false;
        emit(state.copyWith(errorMessage: error.toString()));
      }
      return;
    }
    if (next.organizerJoined) {
      emit(state.copyWith(phase: MeetingRoomPhase.waitingApproval));
      if (_admissionRequested) return;
      _admissionRequested = true;
      try {
        await _repository.requestToJoin();
      } on Object catch (error) {
        _admissionRequested = false;
        emit(state.copyWith(errorMessage: error.toString()));
      }
    } else {
      emit(state.copyWith(phase: MeetingRoomPhase.waitingOrganizer));
    }
  }

  Future<void> _connectMedia(
    MeetingRoomToken token,
    Emitter<MeetingRoomState> emit,
  ) async {
    if (_mediaConnectRequested) return;
    _mediaConnectRequested = true;
    final microphoneEnabled = state.microphoneEnabled;
    final cameraEnabled = state.cameraEnabled;
    emit(state.copyWith(phase: MeetingRoomPhase.joiningMedia));
    try {
      await _repository.connectMedia(token);
      if (microphoneEnabled) {
        await _repository.setMicrophoneEnabled(true);
      }
      if (cameraEnabled) {
        await _repository.setCameraEnabled(true);
      }
    } on Object catch (error) {
      _mediaConnectRequested = false;
      _endRequested = false;
      emit(
        state.copyWith(
          phase: MeetingRoomPhase.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onMediaEvent(
    _MediaEventReceived event,
    Emitter<MeetingRoomState> emit,
  ) {
    final media = event.event;
    switch (media.type) {
      case MeetingMediaEventType.connected:
      case MeetingMediaEventType.reconnected:
        final participants = _preserveParticipantFlags(media.participants);
        final local = _localParticipant(participants);
        emit(
          state.copyWith(
            phase: MeetingRoomPhase.connected,
            participants: participants,
            microphoneEnabled: media.microphoneEnabled,
            cameraEnabled: media.cameraEnabled,
            handRaised: local?.handRaised ?? state.handRaised,
            screenSharing: local?.screenSharing ?? state.screenSharing,
            clearError: true,
          ),
        );
      case MeetingMediaEventType.participantsChanged:
      case MeetingMediaEventType.localMediaChanged:
        final participants = _preserveParticipantFlags(media.participants);
        final local = _localParticipant(participants);
        emit(
          state.copyWith(
            participants: participants,
            microphoneEnabled: media.microphoneEnabled,
            cameraEnabled: media.cameraEnabled,
            handRaised: local?.handRaised ?? state.handRaised,
            screenSharing: local?.screenSharing ?? state.screenSharing,
          ),
        );
      case MeetingMediaEventType.reconnecting:
        emit(state.copyWith(phase: MeetingRoomPhase.reconnecting));
      case MeetingMediaEventType.disconnected:
        if (state.phase != MeetingRoomPhase.left &&
            state.phase != MeetingRoomPhase.ended) {
          emit(state.copyWith(phase: MeetingRoomPhase.reconnecting));
        }
      case MeetingMediaEventType.failure:
        emit(
          state.copyWith(
            phase: MeetingRoomPhase.failure,
            errorMessage: media.message,
          ),
        );
      case MeetingMediaEventType.dataReceived:
        final data = media.dataMessage;
        if (data == null) return;
        if (data.type == 'chat' && data.text?.trim().isNotEmpty == true) {
          emit(state.copyWith(messages: [...state.messages, data]));
        } else if (data.type == 'reaction' && data.reaction != null) {
          final reaction = data.id == null
              ? MeetingRoomDataMessage(
                  type: data.type,
                  id: _reactionId(),
                  senderIdentity: data.senderIdentity,
                  senderName: data.senderName,
                  text: data.text,
                  reaction: data.reaction,
                  raised: data.raised,
                  sentAt: data.sentAt,
                )
              : data;
          emit(
            state.copyWith(
              reactions: _appendReaction(state.reactions, reaction),
            ),
          );
        } else if (data.type == 'hand_raise' && data.raised != null) {
          emit(
            state.copyWith(
              participants: _withRemoteHand(
                state.participants,
                data.senderIdentity,
                data.raised!,
              ),
            ),
          );
        }
      case MeetingMediaEventType.devicesChanged:
        emit(
          state.copyWith(
            audioInputs: media.audioInputs,
            audioOutputs: media.audioOutputs,
            videoInputs: media.videoInputs,
          ),
        );
    }
  }

  String _reactionId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${state.reactions.length}';

  List<MeetingRoomDataMessage> _appendReaction(
    List<MeetingRoomDataMessage> current,
    MeetingRoomDataMessage reaction,
  ) {
    const maxActiveReactions = 12;
    final next = [...current, reaction];
    if (next.length <= maxActiveReactions) return next;
    return next.sublist(next.length - maxActiveReactions);
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    await _mediaSubscription?.cancel();
    await _repository.close();
    return super.close();
  }
}

class _RealtimeMessageReceived extends MeetingRoomEvent {
  const _RealtimeMessageReceived(this.message);

  final MeetingRealtimeMessage message;

  @override
  List<Object?> get props => [message];
}

class _MediaEventReceived extends MeetingRoomEvent {
  const _MediaEventReceived(this.event);

  final MeetingMediaEvent event;

  @override
  List<Object?> get props => [event];
}
