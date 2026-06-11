enum LoadingScreenStatus { userLoading, userSyncing, finished, retryableError }

enum LoadingSteps { loadUserProfiles, syncLoadedUsers }

class LoadingScreenState {
  const LoadingScreenState({required this.status});

  factory LoadingScreenState.initial() {
    return const LoadingScreenState(status: LoadingScreenStatus.userLoading);
  }

  final LoadingScreenStatus status;

  bool get canRetry => status == LoadingScreenStatus.retryableError;

  bool get hasLoadedUsers {
    return switch (status) {
      LoadingScreenStatus.userLoading => false,
      LoadingScreenStatus.userSyncing || LoadingScreenStatus.finished => true,
      LoadingScreenStatus.retryableError => false,
    };
  }

  bool get hasSyncedUsers {
    return switch (status) {
      LoadingScreenStatus.userLoading ||
      LoadingScreenStatus.userSyncing => false,
      LoadingScreenStatus.finished => true,
      LoadingScreenStatus.retryableError => false,
    };
  }

  LoadingScreenState copyWith({LoadingScreenStatus? status}) {
    return LoadingScreenState(status: status ?? this.status);
  }
}
