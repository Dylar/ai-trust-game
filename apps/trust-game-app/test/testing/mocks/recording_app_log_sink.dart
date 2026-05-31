import 'package:app/core/logging/app_logger.dart';

class RecordingAppLogSink implements AppLogSink {
  final List<AppLogEvent> events = <AppLogEvent>[];

  @override
  Future<void> write(AppLogEvent event) async {
    events.add(event);
  }
}
