import '../../models/session_models.dart';

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
