import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/meeting_room.dart';
import '../../domain/repository/meeting_room_repository.dart';
import '../../domain/usecases/close_meeting_usecase.dart';
import 'meeting_room_event.dart';
import 'meeting_room_state.dart';

class MeetingRoomBloc extends Bloc<MeetingRoomEvent, MeetingRoomState> {
  MeetingRoomBloc({
    required MeetingRoomRepository repository,
    required CloseMeetingUseCase closeMeeting,
  }) : _repository = repository,
       _closeMeeting = closeMeeting,
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
    emit(state.copyWith(meetingId: event.meetingId, clearError: true));
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
      case 'meeting_ended':
        await _repository.close();
        emit(state.copyWith(phase: MeetingRoomPhase.ended));
      case 'error':
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
        emit(
          state.copyWith(
            phase: MeetingRoomPhase.connected,
            participants: media.participants,
            microphoneEnabled: media.microphoneEnabled,
            cameraEnabled: media.cameraEnabled,
            clearError: true,
          ),
        );
      case MeetingMediaEventType.participantsChanged:
      case MeetingMediaEventType.localMediaChanged:
        emit(
          state.copyWith(
            participants: media.participants,
            microphoneEnabled: media.microphoneEnabled,
            cameraEnabled: media.cameraEnabled,
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
    }
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
