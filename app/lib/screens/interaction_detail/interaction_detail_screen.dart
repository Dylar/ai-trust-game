import 'package:app/core/app/api_error_localizations.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_keys.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:flutter/material.dart';

class InteractionDetailScreen extends StatefulWidget {
  const InteractionDetailScreen({super.key, required this.viewModel});

  static const routeName = '/interaction-detail';
  final InteractionDetailViewModel viewModel;

  static Future<T?> open<T>(BuildContext context, {required String requestId}) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: InteractionDetailRouteArgs(requestId: requestId),
    );
  }

  @override
  State<InteractionDetailScreen> createState() =>
      _InteractionDetailScreenState();
}

class InteractionDetailRouteArgs {
  const InteractionDetailRouteArgs({required this.requestId});

  final String requestId;
}

class _InteractionDetailScreenState extends State<InteractionDetailScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: InteractionDetailKeys.screen,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<InteractionDetailScreenState>(
              valueListenable: widget.viewModel.state,
              builder: (context, state, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: _InteractionDetailContent(state: state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractionDetailContent extends StatelessWidget {
  const _InteractionDetailContent({required this.state});

  final InteractionDetailScreenState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      InteractionDetailStatus.loading => const _LoadingState(),
      InteractionDetailStatus.ready => _RequestAnalysisView(
        analysis: state.analysis!,
      ),
      InteractionDetailStatus.error => _ErrorState(error: state.error),
    };
  }
}

class _RequestAnalysisView extends StatelessWidget {
  const _RequestAnalysisView({required this.analysis});

  final RequestAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.interactionDetailTitle,
          key: InteractionDetailKeys.title,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.large),
        Card(
          key: InteractionDetailKeys.analysisSection,
          elevation: 0,
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricRow(
                  label: l10n.analysisRequestIdLabel,
                  value: analysis.requestId,
                ),
                _MetricRow(
                  label: l10n.analysisSessionIdLabel,
                  value: analysis.sessionId,
                ),
                _MetricRow(
                  label: l10n.analysisClassificationLabel,
                  value: analysis.classification,
                ),
                _MetricRow(
                  label: l10n.analysisEventCountLabel,
                  value: analysis.eventCount.toString(),
                ),
                _MetricRow(
                  label: l10n.analysisSuspicionCountLabel,
                  value: analysis.suspicionCount.toString(),
                ),
                _MetricRow(
                  label: l10n.analysisModelFailCountLabel,
                  value: analysis.modelFailCount.toString(),
                ),
                _ListBlock(
                  label: l10n.analysisSignalsLabel,
                  values: analysis.signals,
                ),
                _ListBlock(
                  label: l10n.analysisAttackPatternsLabel,
                  values: analysis.attackPatterns,
                ),
                if (analysis.intentSummary.isNotEmpty)
                  _MetricRow(
                    label: l10n.analysisIntentSummaryLabel,
                    value: analysis.intentSummary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.brandForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final renderedValues = values.isEmpty
        ? AppLocalizations.of(context)!.analysisEmptyListValue
        : values.join(', ');

    return _MetricRow(label: label, value: renderedValues);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: InteractionDetailKeys.loadingState,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xLarge),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final InteractionDetailError? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      key: InteractionDetailKeys.errorState,
      elevation: 0,
      color: AppColors.errorSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error?.code == null
                  ? l10n.analysisLoadErrorDescription
                  : l10n.apiErrorDescription(error!.code),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (error?.httpStatusCode != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(l10n.analysisHttpError(error!.httpStatusCode!)),
            ],
          ],
        ),
      ),
    );
  }
}
