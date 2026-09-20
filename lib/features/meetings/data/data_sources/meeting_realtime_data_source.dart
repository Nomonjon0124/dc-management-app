import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/util/lenient_json.dart';
import '../../domain/entities/meeting_room.dart';
import '../models/meeting_realtime_message_model.dart';

abstract interface class MeetingRealtimeDataSource {
  Stream<MeetingRealtimeMessage> get events;

  Future<void> open(int meetingId);

  Future<void> send(Map<String, dynamic> action);

  Future<void> close();
}

class MeetingRealtimeDataSourceImpl implements MeetingRealtimeDataSource {
  MeetingRealtimeDataSourceImpl({
    required DioClient client,
    required LoggerService logger,
  }) : _client = client,
       _logger = logger;

  final DioClient _client;
  final LoggerService _logger;
  final _events = StreamController<MeetingRealtimeMessage>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  int? _meetingId;
  int _attempt = 0;
  bool _active = false;

  @override
  Stream<MeetingRealtimeMessage> get events => _events.stream;

  @override
  Future<void> open(int meetingId) async {
    _meetingId = meetingId;
    _active = true;
    _attempt = 0;
    _reconnectTimer?.cancel();
    await _open();
  }

  Future<void> _open() async {
    final meetingId = _meetingId;
    if (!_active || meetingId == null) return;

    try {
      final response = await _client.post(ApiConstants.notificationsTickets);
      final data = ResponseMapper.asMap(response.data);
      final ticket = data['ticket']?.toString() ?? '';
      if (ticket.isEmpty) throw const ServerException('Ticket olinmadi');

      final channel = WebSocketChannel.connect(
        Uri.parse(ApiConstants.meetingSocket(meetingId, ticket)),
      );
      await channel.ready;
      _channel = channel;
      _attempt = 0;
      _subscription = channel.stream.listen(
        _onData,
        onError: (Object error) {
          _logger.log('Meeting socket xatosi: $error');
          _emitSocketError(error.toString());
          _scheduleReconnect();
        },
        onDone: () {
          _logger.log('Meeting socket yopildi');
          _emitSocketError('Meeting ulanishi uzildi');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } on DioException catch (error) {
      _emitSocketError(ResponseMapper.mapDioException(error).toString());
      _scheduleReconnect();
      rethrow;
    } on Object catch (error) {
      _emitSocketError(error.toString());
      _scheduleReconnect();
      rethrow;
    }
  }

  void _onData(dynamic raw) {
    final decoded = lenientJsonDecode(raw is String ? raw : raw.toString());
    if (decoded == null) {
      _emitSocketError('Meeting serveridan yaroqsiz xabar keldi');
      return;
    }
    _events.add(MeetingRealtimeMessageModel.fromJson(decoded));
  }

  void _emitSocketError(String message) {
    if (!_events.isClosed) {
      _events.add(
        MeetingRealtimeMessageModel(type: 'socket_error', message: message),
      );
    }
  }

  void _scheduleReconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    if (!_active || _meetingId == null) return;
    _reconnectTimer?.cancel();
    _attempt++;
    final seconds = (2 * _attempt).clamp(2, 30);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _open().catchError((_) {});
    });
  }

  @override
  Future<void> send(Map<String, dynamic> action) async {
    final channel = _channel;
    if (channel == null) {
      throw const NetworkException('Meeting serveriga ulanish mavjud emas');
    }
    channel.sink.add(jsonEncode(action));
  }

  @override
  Future<void> close() async {
    _active = false;
    _meetingId = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await close();
    await _events.close();
  }
}
