import 'package:flutter/material.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:app/screens/session_detail/session_detail_screen.dart';
import 'package:app/screens/session_start/session_start_localizations.dart';

class CompactInteractionHeader extends StatelessWidget {
  const CompactInteractionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.interactionTitle,
      key: InteractionKeys.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.brandForeground,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class InteractionHeader extends StatelessWidget {
  const InteractionHeader({super.key});

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

class SessionDetailsSection extends StatelessWidget {
  const SessionDetailsSection({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      key: InteractionKeys.sessionDetailsSection,
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.interactionSessionDetailsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      SessionDetailScreen.open(context, sessionId: session.id),
                  child: Text(l10n.sessionAnalysisButton),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.compact),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.compact,
              children: [
                _SessionDetailChip(
                  key: InteractionKeys.sessionIdItem,
                  label: l10n.interactionSessionIdLabel,
                  value: session.id,
                ),
                _SessionDetailChip(
                  key: InteractionKeys.roleItem,
                  label: l10n.interactionRoleLabel,
                  value: session.role.localizedLabel(l10n),
                ),
                _SessionDetailChip(
                  key: InteractionKeys.modeItem,
                  label: l10n.interactionModeLabel,
                  value: session.mode.localizedLabel(l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDetailChip extends StatelessWidget {
  const _SessionDetailChip({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.compact),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.compact,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: theme.textTheme.labelLarge,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.brandForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: value, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
