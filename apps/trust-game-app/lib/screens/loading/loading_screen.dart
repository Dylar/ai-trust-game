import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/loading/loading_keys.dart';
import 'package:app/screens/loading/loading_screen_state.dart';
import 'package:app/screens/loading/loading_view_model.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.viewModel});

  final LoadingViewModel viewModel;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  LoadingViewModel get _viewModel => widget.viewModel;

  LoadingScreenState get _state => _viewModel.state;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
    _viewModel.stateNotifier.addListener(onStateChanged);
  }

  void onStateChanged() {
    switch (_state.status) {
      case LoadingScreenStatus.userLoading:
      case LoadingScreenStatus.userSyncing:
      case LoadingScreenStatus.retryableError:
        break;
      case LoadingScreenStatus.finished:
        LoginScreen.replace(context);
        break;
    }
  }

  @override
  void dispose() {
    _viewModel.stateNotifier.removeListener(onStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: LoadingKeys.screen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ValueListenableBuilder<LoadingScreenState>(
              valueListenable: _viewModel.stateNotifier,
              builder: (context, state, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.status != LoadingScreenStatus.finished) ...[
                      const CircularProgressIndicator(
                        key: LoadingKeys.loadingIndicator,
                      ),
                      const SizedBox(height: AppSpacing.large),
                    ],
                    _LoadingStepList(state: state),
                    if (state.canRetry) ...[
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        l10n.loadingErrorMessage,
                        key: LoadingKeys.statusMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        l10n.loadingStatusMessage,
                        key: LoadingKeys.statusMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                    if (state.canRetry) ...[
                      const SizedBox(height: AppSpacing.large),
                      FilledButton(
                        key: LoadingKeys.retryButton,
                        onPressed: _viewModel.load,
                        child: Text(l10n.loadingRetryButton),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingStepList extends StatelessWidget {
  const _LoadingStepList({required this.state});

  final LoadingScreenState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LoadingStep(
          label: AppLocalizations.of(context)!.loadingUserProfilesStep,
          isCompleted: state.hasLoadedUsers,
          isActive: state.status == LoadingScreenStatus.userLoading,
        ),
        const SizedBox(height: AppSpacing.small),
        _LoadingStep(
          label: AppLocalizations.of(context)!.loadingSyncSavedUsersStep,
          isCompleted: state.hasSyncedUsers,
          isActive: state.status == LoadingScreenStatus.userSyncing,
        ),
      ],
    );
  }
}

class _LoadingStep extends StatelessWidget {
  const _LoadingStep({
    required this.label,
    required this.isCompleted,
    required this.isActive,
  });

  final String label;
  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: color,
        ),
        const SizedBox(width: AppSpacing.small),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
