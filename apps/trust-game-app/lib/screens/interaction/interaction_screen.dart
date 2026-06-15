import 'package:app/core/app/app_error_dialog.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/interaction/interaction_chat.dart';
import 'package:app/screens/interaction/interaction_header.dart';
import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:flutter/material.dart';

class InteractionRouteArgs {
  const InteractionRouteArgs({required this.sessionId});

  final String sessionId;
}

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({super.key, required this.viewModel});

  static const routeName = '/interaction';
  final InteractionViewModel viewModel;

  static Future<T?> open<T>(BuildContext context, {required String sessionId}) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: InteractionRouteArgs(sessionId: sessionId),
    );
  }

  static Future<T?> replace<T extends Object?, TO extends Object?>(
    BuildContext context, {
    required String sessionId,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: InteractionRouteArgs(sessionId: sessionId),
    );
  }

  @override
  State<InteractionScreen> createState() => _InteractionScreenState();
}

class _InteractionScreenState extends State<InteractionScreen> {
  InteractionViewModel get _viewModel => widget.viewModel;

  InteractionScreenState get _state => _viewModel.state;

  final ScrollController _scrollController = ScrollController();
  bool _isShowingErrorDialog = false;
  int _lastInteractionCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.stateNotifier.addListener(_handleStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStateChanged();
    });
  }

  @override
  void dispose() {
    _viewModel.stateNotifier.removeListener(_handleStateChanged);
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    if (!mounted) {
      return;
    }

    if (_state.error != null && !_isShowingErrorDialog) {
      _showInteractionErrorDialog();
      return;
    }

    if (_state.status == InteractionScreenStatus.error &&
        !_isShowingErrorDialog) {
      _showLoadErrorDialog();
      return;
    }

    if (_state.interactions.length > _lastInteractionCount) {
      _lastInteractionCount = _state.interactions.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) {
          return;
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    } else {
      _lastInteractionCount = _state.interactions.length;
    }
  }

  void _showInteractionErrorDialog() {
    _isShowingErrorDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      await showAppErrorDialog(
        context: context,
        title: l10n.interactionSendErrorTitle,
        message: l10n.interactionSendErrorDescription,
      );
      _isShowingErrorDialog = false;
      _viewModel.clearError();
    });
  }

  void _showLoadErrorDialog() {
    _isShowingErrorDialog = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      await showAppErrorDialog(
        context: context,
        title: l10n.interactionLoadErrorTitle,
        message: l10n.interactionLoadErrorDescription,
      );
      _isShowingErrorDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: InteractionKeys.screen,
      appBar: AppBar(
        title: Text(l10n.interactionTitle, key: InteractionKeys.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<InteractionScreenState>(
              valueListenable: _viewModel.stateNotifier,
              builder: (context, state, _) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: switch (state.status) {
                    InteractionScreenStatus.loading =>
                      const _InteractionScaffold(
                        child: _InteractionLoadingState(),
                      ),
                    InteractionScreenStatus.ready => InteractionReadyContent(
                      state: state,
                      scrollController: _scrollController,
                      onSubmitMessage: _viewModel.submitMessage,
                    ),
                    InteractionScreenStatus.notFound => _InteractionScaffold(
                      child: _SessionNotFoundState(sessionId: state.sessionId),
                    ),
                    InteractionScreenStatus.error => const _InteractionScaffold(
                      child: _InteractionErrorState(),
                    ),
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionScaffold extends StatelessWidget {
  const _InteractionScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InteractionHeader(),
          const SizedBox(height: AppSpacing.large),
          child,
        ],
      ),
    );
  }
}

class _InteractionLoadingState extends StatelessWidget {
  const _InteractionLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: InteractionKeys.loadingState,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xLarge),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _SessionNotFoundState extends StatelessWidget {
  const _SessionNotFoundState({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      key: InteractionKeys.notFoundState,
      elevation: 0,
      color: AppColors.errorSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Text(l10n.interactionNotFoundDescription(sessionId)),
      ),
    );
  }
}

class _InteractionErrorState extends StatelessWidget {
  const _InteractionErrorState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: AppColors.errorSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Text(l10n.interactionLoadErrorDescription),
      ),
    );
  }
}
