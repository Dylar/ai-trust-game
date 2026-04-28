import 'package:app/core/app/api_error_localizations.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';
import 'package:app/screens/session_detail/session_detail_keys.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:flutter/material.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({super.key, required this.viewModel});

  static const routeName = '/session-detail';
  final SessionDetailViewModel viewModel;

  static Future<T?> open<T>(BuildContext context, {required String sessionId}) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: SessionDetailRouteArgs(sessionId: sessionId),
    );
  }

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class SessionDetailRouteArgs {
  const SessionDetailRouteArgs({required this.sessionId});

  final String sessionId;
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: SessionDetailKeys.screen,
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<SessionDetailScreenState>(
              valueListenable: widget.viewModel.state,
              builder: (context, state, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: _SessionDetailContent(state: state),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionDetailContent extends StatelessWidget {
  const _SessionDetailContent({required this.state});

  final SessionDetailScreenState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      SessionDetailStatus.loading => const _LoadingState(),
      SessionDetailStatus.ready => _SessionAnalysisView(
        analysis: state.analysis!,
      ),
      SessionDetailStatus.error => _ErrorState(error: state.error),
    };
  }
}

class _SessionAnalysisView extends StatelessWidget {
  const _SessionAnalysisView({required this.analysis});

  final SessionAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.sessionDetailTitle,
          key: SessionDetailKeys.title,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.large),
        Card(
          key: SessionDetailKeys.analysisSection,
          elevation: 0,
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricRow(
                  label: l10n.analysisSessionIdLabel,
                  value: analysis.sessionId,
                ),
                _MetricRow(
                  label: l10n.analysisClassificationLabel,
                  value: analysis.classification,
                ),
                _MetricRow(
                  label: l10n.analysisRequestCountLabel,
                  value: analysis.requestCount.toString(),
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
        const SizedBox(height: AppSpacing.large),
        _SessionRequestsSection(requests: analysis.requests),
      ],
    );
  }
}

class _SessionRequestsSection extends StatelessWidget {
  const _SessionRequestsSection({required this.requests});

  final List<RequestAnalysis> requests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      key: SessionDetailKeys.requestsSection,
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sessionDetailRequestsTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.sessionDetailRequestsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: AppSpacing.large),
            if (requests.isEmpty)
              Text(l10n.sessionDetailRequestsEmpty)
            else
              Column(
                children: requests
                    .map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _RequestAnalysisCard(request: request),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestAnalysisCard extends StatelessWidget {
  const _RequestAnalysisCard({required this.request});

  final RequestAnalysis request;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      key: SessionDetailKeys.requestCard(request.requestId),
      onTap: () =>
          InteractionDetailScreen.open(context, requestId: request.requestId),
      borderRadius: BorderRadius.circular(AppSpacing.medium),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.medium),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.requestId,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.brandForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.compact),
              Text(
                l10n.sessionDetailRequestSummary(
                  request.classification,
                  request.suspicionCount,
                  request.modelFailCount,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              if (request.intentSummary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.compact),
                Text(
                  request.intentSummary,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
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
      key: SessionDetailKeys.loadingState,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xLarge),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final SessionDetailError? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      key: SessionDetailKeys.errorState,
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
