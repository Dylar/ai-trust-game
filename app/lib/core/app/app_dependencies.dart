import 'package:flutter/widgets.dart';

import '../../data/session/session_api_client.dart';
import '../../data/session/session_repository.dart';
import '../../services/session_service.dart';

class AppDependenciesData {
  const AppDependenciesData({
    required this.sessionRepository,
    required this.sessionService,
  });

  factory AppDependenciesData.defaults() {
    final sessionRepository = InMemorySessionRepository();

    return AppDependenciesData(
      sessionRepository: sessionRepository,
      sessionService: DefaultSessionService(
        sessionRepository: sessionRepository,
        apiClient: SessionApiClient(),
      ),
    );
  }

  final SessionRepository sessionRepository;
  final SessionService sessionService;
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependenciesData dependencies;

  SessionRepository get sessionRepository => dependencies.sessionRepository;
  SessionService get sessionService => dependencies.sessionService;

  static AppDependencies of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(widget != null, 'AppDependencies is missing above this context.');
    return widget!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}
