import 'package:flutter/material.dart';

import '../../core/app/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _InteractionHeader(),
                      const SizedBox(height: AppSpacing.large),
                      if (state.hasSession)
                        _SessionDetailsSection(session: state.session!)
                      else
                        _SessionNotFoundState(sessionId: state.sessionId),
                    ],
                  ),
                );
              },
            ),
          ),
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

  final SessionSummary session;

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
      _InteractionDetailItem(
        key: InteractionKeys.previewItem,
        label: l10n.interactionPreviewLabel,
        value: session.lastMessagePreview,
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
