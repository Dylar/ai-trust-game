import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import 'session_start_localizations.dart';
import 'session_start_screen_state.dart';
import 'session_start_view_model.dart';

class SessionStartScreen extends StatefulWidget {
  const SessionStartScreen({super.key});

  @override
  State<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends State<SessionStartScreen> {
  late final SessionStartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SessionStartViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<SessionStartScreenState>(
              valueListenable: _viewModel.state,
              builder: (context, state, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SessionStartHeader(),
                      const SizedBox(height: 24),
                      _SessionStartFormCard(
                        state: state,
                        l10n: l10n,
                        onRoleSelected: _viewModel.selectRole,
                        onModeSelected: _viewModel.selectMode,
                        onPrepareSession: _viewModel.prepareSession,
                      ),
                      if (state.status == SessionStartStatus.prepared) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _SessionStatusCard(
                          message: l10n.sessionPreparedStatus(
                            state.selectedRole.localizedLabel(l10n),
                            state.selectedMode.localizedLabel(l10n),
                          ),
                        ),
                      ],
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

class _SessionStartHeader extends StatelessWidget {
  const _SessionStartHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.appTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.brandForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(l10n.sessionStartTitle, style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.sessionStartDescription,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _SessionStartFormCard extends StatelessWidget {
  const _SessionStartFormCard({
    required this.state,
    required this.l10n,
    required this.onRoleSelected,
    required this.onModeSelected,
    required this.onPrepareSession,
  });

  final SessionStartScreenState state;
  final AppLocalizations l10n;
  final ValueChanged<SessionRole> onRoleSelected;
  final ValueChanged<SessionMode> onModeSelected;
  final VoidCallback onPrepareSession;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoleSection(
              l10n: l10n,
              selectedRole: state.selectedRole,
              onRoleSelected: onRoleSelected,
            ),
            const SizedBox(height: AppSpacing.large),
            _ModeSection(
              l10n: l10n,
              selectedMode: state.selectedMode,
              onModeSelected: onModeSelected,
            ),
            const SizedBox(height: AppSpacing.small),
            _PrepareSessionButton(
              l10n: l10n,
              isSubmitting: state.isSubmitting,
              onPressed: onPrepareSession,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({
    required this.l10n,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final AppLocalizations l10n;
  final SessionRole selectedRole;
  final ValueChanged<SessionRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.roleSectionTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: SessionRole.values
              .map(
                (role) => _RoleChip(
                  l10n: l10n,
                  role: role,
                  selected: selectedRole == role,
                  onSelected: () => onRoleSelected(role),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.l10n,
    required this.role,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final SessionRole role;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(role.localizedLabel(l10n)),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ModeSection extends StatelessWidget {
  const _ModeSection({
    required this.l10n,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final AppLocalizations l10n;
  final SessionMode selectedMode;
  final ValueChanged<SessionMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.modeSectionTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        Column(
          children: SessionMode.values
              .map(
                (mode) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: _ModeCard(
                    l10n: l10n,
                    mode: mode,
                    selected: selectedMode == mode,
                    onTap: () => onModeSelected(mode),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PrepareSessionButton extends StatelessWidget {
  const _PrepareSessionButton({
    required this.l10n,
    required this.isSubmitting,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      child: Text(
        isSubmitting ? l10n.preparingSessionButton : l10n.prepareSessionButton,
      ),
    );
  }
}

class _SessionStatusCard extends StatelessWidget {
  const _SessionStatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: AppColors.successSurface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Text(message, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.l10n,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final SessionMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : AppColors.borderMuted,
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.localizedLabel(l10n),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.compact),
                    Text(
                      mode.localizedDescription(l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? theme.colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
