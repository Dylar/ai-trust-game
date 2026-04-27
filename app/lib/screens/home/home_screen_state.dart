import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';

class SessionSummary {
  const SessionSummary({required this.session, required this.lastInteraction});

  final Session session;
  final Interaction? lastInteraction;

  String get id => session.id;
  Role get role => session.role;
  Mode get mode => session.mode;
  String? get previewMessage => lastInteraction?.message;
}

class HomeScreenState {
  const HomeScreenState({required this.recentSessions});

  factory HomeScreenState.initial() {
    return const HomeScreenState(recentSessions: <SessionSummary>[]);
  }

  final List<SessionSummary> recentSessions;

  HomeScreenState copyWith({List<SessionSummary>? recentSessions}) {
    return HomeScreenState(
      recentSessions: recentSessions ?? this.recentSessions,
    );
  }
}
