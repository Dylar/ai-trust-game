import 'package:app/services/startup_refresh_service.dart';

enum LoadingScreenStatus { loading, ready }

class LoadingScreenState {
  const LoadingScreenState({
    required this.status,
    required this.message,
    this.result,
  });

  factory LoadingScreenState.loading() {
    return const LoadingScreenState(
      status: LoadingScreenStatus.loading,
      message: 'Loading saved users',
    );
  }

  final LoadingScreenStatus status;
  final String message;
  final StartupRefreshResult? result;

  LoadingScreenState copyWith({
    LoadingScreenStatus? status,
    String? message,
    StartupRefreshResult? result,
  }) {
    return LoadingScreenState(
      status: status ?? this.status,
      message: message ?? this.message,
      result: result ?? this.result,
    );
  }
}
