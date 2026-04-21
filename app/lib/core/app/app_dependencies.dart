import 'package:flutter/widgets.dart';

import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';

class AppDependenciesData {
  const AppDependenciesData({
    required this.interactionRepository,
    required this.interactionService,
    required this.sessionRepository,
    required this.sessionService,
  });

  factory AppDependenciesData.defaults() {
    final interactionRepository = InMemoryInteractionRepository();
    final sessionRepository = InMemorySessionRepository();

    return AppDependenciesData(
      interactionRepository: interactionRepository,
      interactionService: InteractionServiceImpl(
        interactionRepository: interactionRepository,
        apiClient: InteractionApiClient(),
      ),
      sessionRepository: sessionRepository,
      sessionService: SessionServiceImpl(
        sessionRepository: sessionRepository,
        apiClient: SessionApiClient(),
      ),
    );
  }

  final InteractionRepository interactionRepository;
  final InteractionService interactionService;
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

  InteractionRepository get interactionRepository =>
      dependencies.interactionRepository;
  InteractionService get interactionService => dependencies.interactionService;
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
