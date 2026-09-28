import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/call/meeting_call_participant_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';

void main() {
  test('screen-share uses contain while camera keeps cover', () {
    expect(meetingParticipantVideoFit(screenShare: true), VideoViewFit.contain);
    expect(meetingParticipantVideoFit(screenShare: false), VideoViewFit.cover);
  });

  testWidgets('temporary screen-share zoom resets after interaction', (
    tester,
  ) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 320,
          height: 568,
          child: MeetingTemporaryZoomViewer(
            transformationController: controller,
            child: const ColoredBox(color: Colors.black),
          ),
        ),
      ),
    );

    expect(controller.value.getMaxScaleOnAxis(), 1);

    final firstPointer = await tester.createGesture(pointer: 1);
    final secondPointer = await tester.createGesture(pointer: 2);
    await firstPointer.down(const Offset(120, 280));
    await secondPointer.down(const Offset(200, 280));
    await tester.pump();
    await firstPointer.moveTo(const Offset(80, 280));
    await secondPointer.moveTo(const Offset(240, 280));
    await tester.pump();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));

    await firstPointer.up();
    await secondPointer.up();
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), 1);
  });
}
