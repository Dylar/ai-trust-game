import 'package:flutter/widgets.dart';

import '../../data/session/session_api_client.dart';
import '../../services/session_service.dart';

class AppDependenciesData {
  const AppDependenciesData({required this.sessionService});

  const AppDependenciesData.defaults()
    : sessionService = const DefaultSessionService(
        apiClient: SessionApiClient(),
      );

  final SessionService sessionService;
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependenciesData dependencies;

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
