import 'dart:developer' as developer;

import 'package:app/core/logging/app_logger.dart';

class LocalAppLogSink implements AppLogSink {
  const LocalAppLogSink();

  @override
  Future<void> write(AppLogEvent event) async {
    developer.log(
      event.message,
      error: event.error,
      level: _developerLevel(event.level),
      name: event.category,
      stackTrace: event.stackTrace,
      time: event.timestamp,
    );
  }

  int _developerLevel(AppLogLevel level) {
    return switch (level) {
      AppLogLevel.debug => 500,
      AppLogLevel.info => 800,
      AppLogLevel.warning => 900,
      AppLogLevel.error => 1000,
    };
  }
}
