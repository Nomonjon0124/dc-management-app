import 'package:flutter_test/flutter_test.dart';

import 'package:dc_management_app/features/meetings/data/models/meeting_realtime_message_model.dart';

void main() {
  test('parses meeting state and nested LiveKit credential', () {
    final message = MeetingRealtimeMessageModel.fromJson({
      'type': 'meeting_state',
      'meeting_id': 42,
      'requires_approval': false,
      'organizer_joined': true,
      'is_host': true,
      'token': {
        'server_url': 'wss://livekit.example.com',
        'room_name': 'room-42',
        'token': 'secret-token',
      },
    });

    expect(message.type, 'meeting_state');
    expect(message.meetingId, 42);
    expect(message.requiresApproval, isFalse);
    expect(message.organizerJoined, isTrue);
    expect(message.token?.serverUrl, 'wss://livekit.example.com');
    expect(message.token?.roomName, 'room-42');
    expect(message.token?.token, 'secret-token');
  });

  test('does not create a credential from incomplete token data', () {
    final message = MeetingRealtimeMessageModel.fromJson({
      'type': 'token_response',
      'server_url': 'wss://livekit.example.com',
      'room_name': 'room-42',
    });

    expect(message.token, isNull);
  });

  test('parses moderation and approval request fields', () {
    final message = MeetingRealtimeMessageModel.fromJson({
      'type': 'track_unmute_requested',
      'request_id': 'request-1',
      'from_user_id': 7,
      'from_name': 'Organizer',
      'target_identity': '45_phone',
      'track_source': 'microphone',
      'expires_at': '2026-09-24T10:00:00Z',
    });

    expect(message.requestId, 'request-1');
    expect(message.fromUserId, 7);
    expect(message.targetIdentity, '45_phone');
    expect(message.trackSource, 'microphone');
    expect(message.expiresAt, isNotNull);
  });

  test('accepts string error codes from the websocket contract', () {
    final message = MeetingRealtimeMessageModel.fromJson({
      'type': 'error',
      'code': '4004',
      'message': 'Meeting tugagan',
    });

    expect(message.code, 4004);
  });
}
