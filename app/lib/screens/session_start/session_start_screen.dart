import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

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
                      Text(
                        'AI Trust Game',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF123524),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Session Start',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pick the initial role and trust mode for the game. '
                        'This is the first real frontend flow before backend wiring.',
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role', style: theme.textTheme.titleLarge),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: SessionRole.values
                                    .map(
                                      (role) => ChoiceChip(
                                        label: Text(role.label),
                                        selected: state.selectedRole == role,
                                        onSelected: (_) =>
                                            _viewModel.selectRole(role),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                              Text('Mode', style: theme.textTheme.titleLarge),
                              const SizedBox(height: 12),
                              Column(
                                children: SessionMode.values
                                    .map(
                                      (mode) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _ModeCard(
                                          mode: mode,
                                          selected: state.selectedMode == mode,
                                          onTap: () =>
                                              _viewModel.selectMode(mode),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : _viewModel.prepareSession,
                                child: Text(
                                  state.isSubmitting
                                      ? 'Preparing session...'
                                      : 'Prepare session',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.statusMessage != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          color: const Color(0xFFE4F2EA),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              state.statusMessage!,
                              style: theme.textTheme.bodyLarge,
                            ),
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

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
            color: selected
                ? theme.colorScheme.primary
                : const Color(0xFFD8D1C3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mode.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      mode.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
