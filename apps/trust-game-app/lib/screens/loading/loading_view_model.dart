import 'dart:async';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/screens/loading/loading_logger.dart';
import 'package:app/screens/loading/loading_screen_state.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:flutter/foundation.dart';

class LoadingViewModel {
  LoadingViewModel({
    required AppLogger appLogger,
    required AuthService authService,
    required SyncService syncService,
    Duration minimumDisplayDuration = const Duration(seconds: 1),
  }) : _syncService = syncService,
       _authService = authService,
       _logger = LoadingLogger(appLogger: appLogger),
       _minimumDisplayDuration = minimumDisplayDuration,
       stateNotifier = ValueNotifier<LoadingScreenState>(
         LoadingScreenState.initial(),
       );

  // for testing purposes only - allows overriding the minimum display duration to speed up tests
  final Duration _minimumDisplayDuration;

  final LoadingLogger _logger;
  final AuthService _authService;
  final SyncService _syncService;
  final ValueNotifier<LoadingScreenState> stateNotifier;

  LoadingScreenState get state => stateNotifier.value;

  LoadingSteps currentStep = LoadingSteps.loadUserProfiles;

  void dispose() {
    stateNotifier.dispose();
  }

  Future<void> init() async {
    await load();
  }

  Future<void> load() async {
    try {
      stateNotifier.value = LoadingScreenState(
        status: LoadingScreenStatus.userLoading,
      );
      await doStep(
        step: LoadingSteps.loadUserProfiles,
        doIt: _authService.loadUserProfiles,
      );
      stateNotifier.value = LoadingScreenState(
        status: LoadingScreenStatus.userSyncing,
      );
      await doStep(
        step: LoadingSteps.syncStartup,
        doIt: _syncService.syncStartup,
      );
      stateNotifier.value = LoadingScreenState(
        status: LoadingScreenStatus.finished,
      );
    } on Object catch (error, stackTrace) {
      await _logger.logLoadingFailed(
        step: currentStep.name,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = LoadingScreenState(
        status: LoadingScreenStatus.retryableError,
      );
    }
  }

  Future<void> doStep({
    required LoadingSteps step,
    required Future<Object?> Function() doIt,
  }) async {
    currentStep = step;
    final waitAtLeast = Future<void>.delayed(_minimumDisplayDuration);
    final work = doIt();
    await work;
    await waitAtLeast;
  }
}
