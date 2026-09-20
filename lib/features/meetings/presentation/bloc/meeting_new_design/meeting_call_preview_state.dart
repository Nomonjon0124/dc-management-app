import 'package:equatable/equatable.dart';

enum MeetingCallPreviewPhase { prejoin, waiting, call, ended }

enum MeetingCallPreviewSheet {
  participants,
  chat,
  more,
  devices,
  exit,
  details,
  shareScreen,
  camera,
}

class MeetingCallPreviewState extends Equatable {
  const MeetingCallPreviewState({
    this.phase = MeetingCallPreviewPhase.prejoin,
    this.microphoneOn = true,
    this.cameraOn = false,
    this.handRaised = false,
    this.speakerGrid = false,
    this.joinRequest = false,
    this.screenSharing = false,
    this.stickersOpen = false,
    this.frontCamera = true,
    this.blurBackground = true,
    this.microphoneDevice = 'iphone',
    this.speakerDevice = 'iphone',
    this.activeSheet,
    this.participantSearch = '',
    this.reactions = const [],
    this.messages = const [],
  });

  final MeetingCallPreviewPhase phase;
  final bool microphoneOn;
  final bool cameraOn;
  final bool handRaised;
  final bool speakerGrid;
  final bool joinRequest;
  final bool screenSharing;
  final bool stickersOpen;
  final bool frontCamera;
  final bool blurBackground;
  final String microphoneDevice;
  final String speakerDevice;
  final MeetingCallPreviewSheet? activeSheet;
  final String participantSearch;
  final List<String> reactions;
  final List<String> messages;

  MeetingCallPreviewState copyWith({
    MeetingCallPreviewPhase? phase,
    bool? microphoneOn,
    bool? cameraOn,
    bool? handRaised,
    bool? speakerGrid,
    bool? joinRequest,
    bool? screenSharing,
    bool? stickersOpen,
    bool? frontCamera,
    bool? blurBackground,
    String? microphoneDevice,
    String? speakerDevice,
    MeetingCallPreviewSheet? activeSheet,
    bool clearActiveSheet = false,
    String? participantSearch,
    List<String>? reactions,
    List<String>? messages,
  }) {
    return MeetingCallPreviewState(
      phase: phase ?? this.phase,
      microphoneOn: microphoneOn ?? this.microphoneOn,
      cameraOn: cameraOn ?? this.cameraOn,
      handRaised: handRaised ?? this.handRaised,
      speakerGrid: speakerGrid ?? this.speakerGrid,
      joinRequest: joinRequest ?? this.joinRequest,
      screenSharing: screenSharing ?? this.screenSharing,
      stickersOpen: stickersOpen ?? this.stickersOpen,
      frontCamera: frontCamera ?? this.frontCamera,
      blurBackground: blurBackground ?? this.blurBackground,
      microphoneDevice: microphoneDevice ?? this.microphoneDevice,
      speakerDevice: speakerDevice ?? this.speakerDevice,
      activeSheet: clearActiveSheet ? null : activeSheet ?? this.activeSheet,
      participantSearch: participantSearch ?? this.participantSearch,
      reactions: reactions ?? this.reactions,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    microphoneOn,
    cameraOn,
    handRaised,
    speakerGrid,
    joinRequest,
    screenSharing,
    stickersOpen,
    frontCamera,
    blurBackground,
    microphoneDevice,
    speakerDevice,
    activeSheet,
    participantSearch,
    reactions,
    messages,
  ];
}
