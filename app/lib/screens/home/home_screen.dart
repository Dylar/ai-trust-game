import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../session_start/session_start_localizations.dart';
import 'home_keys.dart';
import 'home_screen_state.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onStartSession, this.onResumeSession});

  final VoidCallback? onStartSession;
  final ValueChanged<String>? onResumeSession;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      onStartSession: widget.onStartSession,
      onResumeSession: widget.onResumeSession,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomeKeys.screen,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<HomeScreenState>(
              valueListenable: _viewModel.state,
              builder: (context, state, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeHeader(
                        onStartSession: _viewModel.requestStartSession,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      _RecentSessionsSection(
                        sessions: state.recentSessions,
                        onResumeSession: _viewModel.resumeSession,
                      ),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onStartSession});

  final VoidCallback onStartSession;

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
              key: HomeKeys.title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(l10n.homeTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.homeDescription,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton(
              key: HomeKeys.startSessionButton,
              onPressed: onStartSession,
              child: Text(l10n.homeStartSessionButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionsSection extends StatelessWidget {
  const _RecentSessionsSection({
    required this.sessions,
    required this.onResumeSession,
  });

  final List<HomeSessionItem> sessions;
  final ValueChanged<String> onResumeSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      key: HomeKeys.recentSessionsSection,
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeRecentSessionsTitle,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.homeRecentSessionsDescription,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.large),
            if (sessions.isEmpty)
              _EmptySessionsState(message: l10n.homeEmptySessions)
            else
              Column(
                children: sessions
                    .map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _RecentSessionCard(
                          session: session,
                          onResumeSession: () => onResumeSession(session.id),
                        ),
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

class _EmptySessionsState extends StatelessWidget {
  const _EmptySessionsState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: HomeKeys.emptySessionsState,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.medium),
      ),
      child: Text(message),
    );
  }
}

class _RecentSessionCard extends StatelessWidget {
  const _RecentSessionCard({
    required this.session,
    required this.onResumeSession,
  });

  final HomeSessionItem session;
  final VoidCallback onResumeSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      key: HomeKeys.session(session.id),
      onTap: onResumeSession,
      borderRadius: BorderRadius.circular(AppSpacing.medium),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.medium),
          border: Border.all(color: AppColors.borderMuted),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeSessionSummary(
                  session.role.localizedLabel(l10n),
                  session.mode.localizedLabel(l10n),
                ),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.compact),
              Text(
                session.lastMessagePreview,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                l10n.homeResumeSessionHint,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
