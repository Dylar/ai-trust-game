import 'package:flutter/material.dart';

import '../../core/app/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/interaction_models.dart';
import '../../models/session_models.dart';
import '../session_start/session_start_localizations.dart';
import 'interaction_keys.dart';
import 'interaction_screen_state.dart';
import 'interaction_view_model.dart';

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
  InteractionViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= InteractionViewModel(
      interactionRepository: AppDependencies.of(context).interactionRepository,
      interactionService: AppDependencies.of(context).interactionService,
      sessionRepository: AppDependencies.of(context).sessionRepository,
      sessionId: widget.sessionId,
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
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
                    InteractionScreenStatus.ready => _ReadyInteractionContent(
                      state: state,
                      viewModel: _viewModel!,
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
          const _InteractionHeader(),
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

class _ReadyInteractionContent extends StatelessWidget {
  const _ReadyInteractionContent({
    required this.state,
    required this.viewModel,
  });

  final InteractionScreenState state;
  final InteractionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              const _InteractionHeader(),
              const SizedBox(height: AppSpacing.large),
              _SessionDetailsSection(session: state.session!),
              const SizedBox(height: AppSpacing.large),
              _InteractionsSection(interactions: state.interactions),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        _InteractionComposer(state: state, viewModel: viewModel),
      ],
    );
  }
}

class _InteractionComposer extends StatefulWidget {
  const _InteractionComposer({required this.state, required this.viewModel});

  final InteractionScreenState state;
  final InteractionViewModel viewModel;

  @override
  State<_InteractionComposer> createState() => _InteractionComposerState();
}

class _InteractionComposerState extends State<_InteractionComposer> {
  final TextEditingController _messageController = TextEditingController();

  bool get _canSubmit =>
      !widget.state.isSubmitting && _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleMessageChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _handleMessageChanged() {
    setState(() {});
  }

  Future<void> _submitMessage() async {
    if (!_canSubmit) {
      return;
    }

    final message = _messageController.text;
    await widget.viewModel.submitMessage(message);
    if (!mounted) {
      return;
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: InteractionKeys.composerMessageInput,
              controller: _messageController,
              enabled: !widget.state.isSubmitting,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.interactionMessageInputLabel,
                hintText: l10n.interactionMessageInputHint,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: InteractionKeys.composerSendButton,
                onPressed: _canSubmit ? _submitMessage : null,
                child: Text(
                  widget.state.isSubmitting
                      ? l10n.interactionSendButtonLoading
                      : l10n.interactionSendButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionHeader extends StatelessWidget {
  const _InteractionHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              key: InteractionKeys.title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(l10n.interactionTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.interactionDescription,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDetailsSection extends StatelessWidget {
  const _SessionDetailsSection({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detailItems = <_InteractionDetailItem>[
      _InteractionDetailItem(
        key: InteractionKeys.sessionIdItem,
        label: l10n.interactionSessionIdLabel,
        value: session.id,
      ),
      _InteractionDetailItem(
        key: InteractionKeys.roleItem,
        label: l10n.interactionRoleLabel,
        value: session.role.localizedLabel(l10n),
      ),
      _InteractionDetailItem(
        key: InteractionKeys.modeItem,
        label: l10n.interactionModeLabel,
        value: session.mode.localizedLabel(l10n),
      ),
    ];

    return Card(
      key: InteractionKeys.sessionDetailsSection,
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.interactionSessionDetailsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.large),
            ...detailItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: _InteractionDetailRow(item: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection({required this.interactions});

  final List<Interaction> interactions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      key: InteractionKeys.interactionsSection,
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.interactionListTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.large),
            if (interactions.isEmpty)
              _EmptyInteractionsState(message: l10n.interactionListEmpty)
            else
              ...interactions.map(
                (interaction) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: _InteractionCard(interaction: interaction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyInteractionsState extends StatelessWidget {
  const _EmptyInteractionsState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: InteractionKeys.emptyInteractionsState,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      child: Text(message),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: InteractionKeys.interaction(interaction.interactionId),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(interaction.message, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.compact),
          Text(interaction.answer, style: theme.textTheme.bodyLarge),
        ],
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

class _InteractionDetailRow extends StatelessWidget {
  const _InteractionDetailRow({required this.item});

  final _InteractionDetailItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: item.key,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.brandForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(item.value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _InteractionDetailItem {
  const _InteractionDetailItem({
    required this.key,
    required this.label,
    required this.value,
  });

  final Key key;
  final String label;
  final String value;
}
