import 'package:dc_management_app/features/meetings/data/models/meeting_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MeetingModel reads participants from participants_info '
      '(participants is writeOnly and absent in responses)', () {
    final model = MeetingModel.fromJson({
      'id': 7,
      'title': 'Weekly sync',
      'participants_info': [
        {'id': 3, 'username': 'ali', 'position': 'Dev', 'avatar': ''},
        {'id': 9, 'username': 'vali', 'position': 'QA', 'avatar': ''},
      ],
    });

    expect(model.participantIds, [3, 9]);
    expect(model.participantsInfo.length, 2);
    expect(model.participantsInfo.first.username, 'ali');
    expect(model.participantsInfo.last.position, 'QA');
  });

  test('MeetingModel preserves the API meeting wall-clock time', () {
    final model = MeetingModel.fromJson({
      'id': 33,
      'start_time': '2026-09-28T15:40:00+05:00',
    });

    expect(model.startDate?.hour, 15);
    expect(model.startDate?.minute, 40);
    expect(model.startDate?.isUtc, isFalse);
  });
}
