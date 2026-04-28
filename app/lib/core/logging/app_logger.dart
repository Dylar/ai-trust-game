import 'dart:async';

enum AppLogLevel { debug, info, warning, error }

class AppLogEvent {
  AppLogEvent({
    required this.level,
    required this.category,
    required this.message,
    this.attributes = const <String, Object?>{},
    this.error,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  final Map<String, Object?> attributes;
  final String category;
  final Object? error;
  final AppLogLevel level;
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;
}

abstract interface class AppLogSink {
  Future<void> write(AppLogEvent event);
}

class AppLogger {
  const AppLogger({required this.sinks});

  final List<AppLogSink> sinks;

  Future<void> log(AppLogEvent event) async {
    for (final sink in sinks) {
      await sink.write(event);
    }
  }
}
