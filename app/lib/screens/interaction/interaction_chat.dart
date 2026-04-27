import 'package:flutter/material.dart';

import 'package:app/core/app/api_error_localizations.dart';
import 'package:app/core/app/app_error_dialog.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/screens/interaction/interaction_header.dart';
import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';

class InteractionReadyContent extends StatefulWidget {
  const InteractionReadyContent({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onSubmitMessage,
    required this.onErrorShown,
  });

  final InteractionScreenState state;
  final ScrollController scrollController;
  final Future<void> Function(String message) onSubmitMessage;
  final VoidCallback onErrorShown;

  @override
  State<InteractionReadyContent> createState() =>
      _InteractionReadyContentState();
}

class _InteractionReadyContentState extends State<InteractionReadyContent> {
  final TextEditingController _messageController = TextEditingController();
  var _isErrorDialogOpen = false;
  var _lastInteractionCount = 0;

  @override
  void initState() {
    super.initState();
    _lastInteractionCount = widget.state.interactions.length;
  }

  @override
  void didUpdateWidget(InteractionReadyContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.interactions.length > _lastInteractionCount) {
      _messageController.clear();
    }
    _lastInteractionCount = widget.state.interactions.length;

    final error = widget.state.error;
    if (error != null && !_isErrorDialogOpen) {
      _isErrorDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }

        await _showErrorDialog(error);
        widget.onErrorShown();
        _isErrorDialogOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showErrorDialog(InteractionScreenError error) {
    final l10n = AppLocalizations.of(context)!;

    return showAppErrorDialog(
      context: context,
      title: l10n.interactionSendErrorTitle,
      message: error.code == null
          ? l10n.interactionSendErrorDescription
          : l10n.apiErrorDescription(error.code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CompactInteractionHeader(),
        const SizedBox(height: AppSpacing.medium),
        SessionDetailsSection(session: widget.state.session!),
        const SizedBox(height: AppSpacing.medium),
        Expanded(
          child: _InteractionsSection(
            controller: widget.scrollController,
            interactions: widget.state.interactions,
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        _InteractionComposer(
          isSubmitting: widget.state.isSubmitting,
          messageController: _messageController,
          onSubmit: widget.onSubmitMessage,
        ),
      ],
    );
  }
}

class _InteractionComposer extends StatefulWidget {
  const _InteractionComposer({
    required this.isSubmitting,
    required this.messageController,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final TextEditingController messageController;
  final Future<void> Function(String message) onSubmit;

  @override
  State<_InteractionComposer> createState() => _InteractionComposerState();
}

class _InteractionComposerState extends State<_InteractionComposer> {
  bool get _canSubmit =>
      !widget.isSubmitting && widget.messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_handleMessageChanged);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_handleMessageChanged);
    super.dispose();
  }

  void _handleMessageChanged() {
    setState(() {});
  }

  Future<void> _submitMessage() async {
    if (!_canSubmit) {
      return;
    }

    await widget.onSubmit(widget.messageController.text);
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
              controller: widget.messageController,
              enabled: !widget.isSubmitting,
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
                  widget.isSubmitting
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

class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection({
    required this.controller,
    required this.interactions,
  });

  final ScrollController controller;
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
        child: ListView(
          controller: controller,
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
    final l10n = AppLocalizations.of(context)!;

    return Ink(
      key: InteractionKeys.interaction(interaction.interactionId),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MessageBubble(
              label: l10n.interactionUserMessageLabel,
              message: interaction.message,
              alignment: Alignment.centerRight,
              backgroundColor: AppColors.infoSurface,
              borderColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.small),
            _MessageBubble(
              label: l10n.interactionAssistantMessageLabel,
              message: interaction.answer,
              alignment: Alignment.centerLeft,
              backgroundColor: AppColors.surface,
              borderColor: AppColors.borderMuted,
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.small,
              children: [
                TextButton(
                  onPressed: () => InteractionDetailScreen.open(
                    context,
                    requestId: interaction.interactionId,
                  ),
                  child: Text(l10n.interactionAnalysisHint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.label,
    required this.message,
    required this.alignment,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final String message;
  final Alignment alignment;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.small),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.brandForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.compact),
                Text(message, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
