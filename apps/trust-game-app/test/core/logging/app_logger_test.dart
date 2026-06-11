import 'package:app/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fanout logger forwards events to every sink', () async {
    final firstSink = _RecordingSink();
    final secondSink = _RecordingSink();
    final event = AppLogEvent(
      level: AppLogLevel.info,
      category: 'interaction',
      message: 'Sent message',
      attributes: <String, Object?>{'sessionId': 'session-1'},
    );
    final logger = AppLogger(sinks: <AppLogSink>[firstSink, secondSink]);

    await logger.log(event);

    expect(firstSink.events, <AppLogEvent>[event]);
    expect(secondSink.events, <AppLogEvent>[event]);
  });

  test('fanout logger continues when one sink fails', () async {
    final recordingSink = _RecordingSink();
    final event = AppLogEvent(
      level: AppLogLevel.error,
      category: 'login',
      message: 'Failed',
    );
    final logger = AppLogger(
      sinks: <AppLogSink>[_FailingSink(), recordingSink],
    );

    await logger.log(event);

    expect(recordingSink.events, <AppLogEvent>[event]);
  });
}

class _RecordingSink implements AppLogSink {
  final List<AppLogEvent> events = <AppLogEvent>[];

  @override
  Future<void> write(AppLogEvent event) async {
    events.add(event);
  }
}

class _FailingSink implements AppLogSink {
  @override
  Future<void> write(AppLogEvent event) async {
    throw Exception('sink failed');
  }
}
