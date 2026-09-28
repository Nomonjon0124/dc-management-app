import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/gen/assets.gen.dart';

enum MeetingSound {
  participantJoined,
  knockRequest,
  handRaised,
  chatMessage,
  screenShareStartStop,
}

abstract interface class MeetingSoundService {
  Future<void> initialize();

  Future<void> playParticipantJoined();

  Future<void> playKnockRequest();

  Future<void> playHandRaised();

  Future<void> playChatMessage();

  Future<void> playScreenShareStartStop();

  Future<void> dispose();
}

class MeetingSoundServiceImpl implements MeetingSoundService {
  MeetingSoundServiceImpl();

  final Map<MeetingSound, AudioPool> _pools = {};
  Future<void>? _initialization;
  bool _disposed = false;

  @override
  Future<void> initialize() {
    if (_disposed) return Future<void>.value();
    return _initialization ??= _initializePools();
  }

  Future<void> _initializePools() async {
    final assets = <MeetingSound, String>{
      MeetingSound.participantJoined: Assets.audio.meeting.participantJoined,
      MeetingSound.knockRequest: Assets.audio.meeting.knockRequest,
      MeetingSound.handRaised: Assets.audio.meeting.handRaised,
      MeetingSound.chatMessage: Assets.audio.meeting.chatMessage,
      MeetingSound.screenShareStartStop:
          Assets.audio.meeting.screenShareStartStop,
    };

    for (final entry in assets.entries) {
      try {
        final pool = await AudioPool.createFromAsset(
          path: _relativeAssetPath(entry.value),
          minPlayers: 1,
          maxPlayers: 2,
        );
        if (_disposed) {
          await pool.dispose();
        } else {
          _pools[entry.key] = pool;
        }
      } on Object catch (error, stackTrace) {
        debugPrint(
          'Meeting sound init failed for ${entry.key}: $error\n$stackTrace',
        );
      }
    }
  }

  String _relativeAssetPath(String path) {
    const prefix = 'assets/';
    return path.startsWith(prefix) ? path.substring(prefix.length) : path;
  }

  Future<void> _play(MeetingSound sound) async {
    try {
      await initialize();
      await _pools[sound]?.start(volume: 0.65);
    } on Object catch (error, stackTrace) {
      debugPrint(
        'Meeting sound playback failed for $sound: $error\n$stackTrace',
      );
    }
  }

  @override
  Future<void> playParticipantJoined() => _play(MeetingSound.participantJoined);

  @override
  Future<void> playKnockRequest() => _play(MeetingSound.knockRequest);

  @override
  Future<void> playHandRaised() => _play(MeetingSound.handRaised);

  @override
  Future<void> playChatMessage() => _play(MeetingSound.chatMessage);

  @override
  Future<void> playScreenShareStartStop() =>
      _play(MeetingSound.screenShareStartStop);

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _initialization;
    final pools = _pools.values.toList(growable: false);
    _pools.clear();
    _initialization = null;
    for (final pool in pools) {
      try {
        await pool.dispose();
      } on Object catch (error, stackTrace) {
        debugPrint('Meeting sound dispose failed: $error\n$stackTrace');
      }
    }
  }
}

class NoopMeetingSoundService implements MeetingSoundService {
  const NoopMeetingSoundService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> playParticipantJoined() async {}

  @override
  Future<void> playKnockRequest() async {}

  @override
  Future<void> playHandRaised() async {}

  @override
  Future<void> playChatMessage() async {}

  @override
  Future<void> playScreenShareStartStop() async {}

  @override
  Future<void> dispose() async {}
}
