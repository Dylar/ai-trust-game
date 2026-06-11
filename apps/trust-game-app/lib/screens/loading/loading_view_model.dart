import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:app/screens/loading/loading_screen_state.dart';
import 'package:app/services/startup_refresh_service.dart';

class LoadingViewModel {
  LoadingViewModel({
    required this.startupRefreshService,
    this.minimumDisplayDuration = const Duration(seconds: 1),
  }) : state = ValueNotifier<LoadingScreenState>(LoadingScreenState.loading());

  final StartupRefreshService startupRefreshService;
  final Duration minimumDisplayDuration;
  final ValueNotifier<LoadingScreenState> state;

  Future<StartupRefreshResult> load() async {
    state.value = LoadingScreenState.loading();
    final refresh = startupRefreshService.refreshKnownUsers();
    await Future.wait<void>([
      refresh.then((_) {}),
      Future<void>.delayed(minimumDisplayDuration),
    ]);
    final result = await refresh;
    state.value = LoadingScreenState(
      status: LoadingScreenStatus.ready,
      message: _messageFor(result),
      result: result,
    );
    return result;
  }

  void dispose() {
    state.dispose();
  }
}

String _messageFor(StartupRefreshResult result) {
  return switch (result.status) {
    StartupRefreshStatus.noKnownUsers => 'User selection required',
    StartupRefreshStatus.refreshed => 'Saved users refreshed',
    StartupRefreshStatus.offlineFallback => 'Offline mode uses saved data',
    StartupRefreshStatus.partialFailure => 'Some saved users could not refresh',
  };
}
