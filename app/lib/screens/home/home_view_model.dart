import 'package:flutter/foundation.dart';

import 'home_screen_state.dart';

class HomeViewModel {
  HomeViewModel({this.onStartSession, this.onResumeSession})
    : state = ValueNotifier(HomeScreenState.initial());

  final VoidCallback? onStartSession;
  final ValueChanged<String>? onResumeSession;
  final ValueNotifier<HomeScreenState> state;

  void requestStartSession() {
    onStartSession?.call();
  }

  void resumeSession(String sessionId) {
    onResumeSession?.call(sessionId);
  }

  void dispose() {
    state.dispose();
  }
}
