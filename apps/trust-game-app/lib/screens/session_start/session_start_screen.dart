import 'package:app/core/app/app_error_dialog.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen.dart';
import 'package:app/screens/session_start/session_start_keys.dart';
import 'package:app/screens/session_start/session_start_localizations.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/screens/session_start/session_start_view_model.dart';
import 'package:flutter/material.dart';

class SessionStartScreen extends StatefulWidget {
  const SessionStartScreen({super.key, required this.viewModel});

  static const routeName = '/session-start';

  final SessionStartViewModel viewModel;

  static Future<T?> open<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(routeName);
  }

  @override
  State<SessionStartScreen> createState() => _SessionStartScreenState();
}

class _SessionStartScreenState extends State<SessionStartScreen> {
  SessionStartViewModel get _viewModel => widget.viewModel;

  SessionStartScreenState get _state => _viewModel.stateNotifier.value;

  bool _isShowingErrorDialog = false;

  @override
  void initState() {
    super.initState();
    _viewModel.stateNotifier.addListener(_handleStateChanged);
  }

  @override
  void dispose() {
    _viewModel.stateNotifier.removeListener(_handleStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    if (!mounted) {
      return;
    }

    if (_state.status == SessionStartStatus.error && !_isShowingErrorDialog) {
      _isShowingErrorDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }

        await _showErrorDialog();
        _isShowingErrorDialog = false;
      });
      return;
    }

    if (_state.status != SessionStartStatus.prepared ||
        _state.createdSessionId == null) {
      return;
    }

    final sessionId = _state.createdSessionId!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      InteractionScreen.replace(context, sessionId: sessionId);
    });
  }

  Future<void> _showErrorDialog() {
    final l10n = AppLocalizations.of(context)!;

    return showAppErrorDialog(
      context: context,
      title: l10n.sessionStartErrorTitle,
      message: l10n.sessionStartErrorDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: SessionStartKeys.screen,
      appBar: AppBar(
        title: Text(l10n.sessionStartTitle, key: SessionStartKeys.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<SessionStartScreenState>(
              valueListenable: _viewModel.stateNotifier,
              builder: (context, state, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SessionStartHeader(),
                      const SizedBox(height: AppSpacing.large),
                      _SessionStartFormCard(
                        state: state,
                        onRoleSelected: _viewModel.selectRole,
                        onModeSelected: _viewModel.selectMode,
                        onPrepareSession: _viewModel.prepareSession,
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
          key: SessionStartKeys.title,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.brandForeground,
          ),
        ),
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
    required this.onRoleSelected,
    required this.onModeSelected,
    required this.onPrepareSession,
  });

  final SessionStartScreenState state;
  final ValueChanged<Role> onRoleSelected;
  final ValueChanged<Mode> onModeSelected;
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
              selectedRole: state.selectedRole,
              onRoleSelected: onRoleSelected,
            ),
            const SizedBox(height: AppSpacing.large),
            _ModeSection(
              selectedMode: state.selectedMode,
              onModeSelected: onModeSelected,
            ),
            const SizedBox(height: AppSpacing.small),
            _PrepareSessionButton(
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
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final Role selectedRole;
  final ValueChanged<Role> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.roleSectionTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: Role.values
              .map(
                (role) => _RoleChip(
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
    required this.role,
    required this.selected,
    required this.onSelected,
  });

  final Role role;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChoiceChip(
      key: switch (role) {
        Role.guest => SessionStartKeys.roleGuest,
        Role.employee => SessionStartKeys.roleEmployee,
        Role.admin => SessionStartKeys.roleAdmin,
      },
      label: Text(role.localizedLabel(l10n)),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ModeSection extends StatelessWidget {
  const _ModeSection({
    required this.selectedMode,
    required this.onModeSelected,
  });

  final Mode selectedMode;
  final ValueChanged<Mode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.modeSectionTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        Column(
          children: Mode.values
              .map(
                (mode) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: _ModeCard(
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
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilledButton(
      key: SessionStartKeys.prepareButton,
      onPressed: isSubmitting ? null : onPressed,
      child: Text(
        isSubmitting ? l10n.preparingSessionButton : l10n.prepareSessionButton,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final Mode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return InkWell(
      key: switch (mode) {
        Mode.easy => SessionStartKeys.modeEasy,
        Mode.medium => SessionStartKeys.modeMedium,
        Mode.hard => SessionStartKeys.modeHard,
      },
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
                key: switch (mode) {
                  Mode.easy => SessionStartKeys.modeEasyIndicator,
                  Mode.medium => SessionStartKeys.modeMediumIndicator,
                  Mode.hard => SessionStartKeys.modeHardIndicator,
                },
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
