import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/interaction/interaction_chat.dart';
import 'package:app/screens/interaction/interaction_header.dart';
import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:flutter/material.dart';

class InteractionScreen extends StatefulWidget {
  const InteractionScreen({super.key, required this.sessionId});

  static const routeName = '/interaction';

  final String sessionId;

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

class InteractionRouteArgs {
  const InteractionRouteArgs({required this.sessionId});

  final String sessionId;
}

class _InteractionScreenState extends State<InteractionScreen> {
  final ScrollController _scrollController = ScrollController();
  InteractionViewModel? _viewModel;
  int _lastInteractionCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) {
      return;
    }

    _viewModel = InteractionViewModel(
      interactionRepository: AppDependencies.of(context).interactionRepository,
      interactionService: AppDependencies.of(context).interactionService,
      sessionRepository: AppDependencies.of(context).sessionRepository,
      sessionId: widget.sessionId,
    );
    _viewModel?.state.addListener(_handleStateChanged);
  }

  @override
  void dispose() {
    _viewModel?.state.removeListener(_handleStateChanged);
    _viewModel?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    final state = _viewModel?.state.value;
    if (state == null || !mounted) {
      return;
    }

    if (state.interactions.length > _lastInteractionCount) {
      _lastInteractionCount = state.interactions.length;
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
      _lastInteractionCount = state.interactions.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: InteractionKeys.screen,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<InteractionScreenState>(
              valueListenable: _viewModel!.state,
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
                      onSubmitMessage: _viewModel!.submitMessage,
                      onErrorShown: _viewModel!.clearError,
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
