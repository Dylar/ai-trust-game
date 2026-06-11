import 'package:app/core/app/app_error_dialog.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/login/login_keys.dart';
import 'package:app/screens/login/login_screen_state.dart';
import 'package:app/screens/login/login_view_model.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  static const routeName = '/login';

  final LoginViewModel viewModel;

  static Future<T?> replace<T extends Object?, TO extends Object?>(
    BuildContext context,
  ) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(routeName);
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginViewModel get _viewModel => widget.viewModel;

  LoginScreenState get _state => _viewModel.state;

  final _displayNameController = TextEditingController();
  bool _isShowingErrorDialog = false;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
    _viewModel.stateNotifier.addListener(_handleStateChanged);
  }

  @override
  void dispose() {
    _viewModel.stateNotifier.removeListener(_handleStateChanged);
    _displayNameController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleStateChanged() {
    if (!mounted) {
      return;
    }

    if (_state.error != null && !_isShowingErrorDialog) {
      _isShowingErrorDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        await _showErrorDialog(_state.error!);
        _isShowingErrorDialog = false;
        _viewModel.clearError();
      });
      return;
    }

    if (_state.status == LoginScreenStatus.loggedIn) {
      HomeScreen.replace(context);
    }
  }

  Future<void> _showErrorDialog(LoginError error) {
    final l10n = AppLocalizations.of(context)!;
    return showAppErrorDialog(
      context: context,
      title: l10n.loginErrorTitle,
      message: _loginErrorMessage(l10n, error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: LoginKeys.screen,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ValueListenableBuilder<LoginScreenState>(
              valueListenable: _viewModel.stateNotifier,
              builder: (context, state, _) {
                if (state.status == LoginScreenStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LoginHeader(title: l10n.loginTitle),
                      const SizedBox(height: AppSpacing.large),
                      _UserSection(
                        key: LoginKeys.loadedUsersSection,
                        title: l10n.loginLoadedUsersTitle,
                        emptyMessage: l10n.loginLoadedUsersEmpty,
                        emptyKey: LoginKeys.emptyLoadedUsersState,
                        users: state.loadedUsers,
                        isSubmitting: state.isSubmitting,
                        onSelectUser: _viewModel.selectUser,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _UserSection(
                        key: LoginKeys.unloadedUsersSection,
                        title: l10n.loginUnloadedUsersTitle,
                        emptyMessage: l10n.loginUnloadedUsersEmpty,
                        emptyKey: LoginKeys.emptyUnloadedUsersState,
                        users: state.unloadedUsers,
                        isSubmitting: state.isSubmitting,
                        onSelectUser: _viewModel.selectUser,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      _CreateUserSection(
                        controller: _displayNameController,
                        isSubmitting: state.isSubmitting,
                        onCreateUser: () =>
                            _viewModel.createUser(_displayNameController.text),
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

String _loginErrorMessage(AppLocalizations l10n, LoginError error) {
  return switch (error) {
    LoginError.emptyDisplayName => l10n.loginErrorEmptyDisplayName,
    LoginError.loadUsersFailed => l10n.loginErrorLoadUsersFailed,
    LoginError.selectUserFailed => l10n.loginErrorSelectUserFailed,
    LoginError.createUserFailed => l10n.loginErrorCreateUserFailed,
  };
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.brandForeground,
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  const _UserSection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.emptyKey,
    required this.users,
    required this.isSubmitting,
    required this.onSelectUser,
  });

  final String title;
  final String emptyMessage;
  final Key emptyKey;
  final List<UserProfile> users;
  final bool isSubmitting;
  final ValueChanged<UserProfile> onSelectUser;

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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.medium),
            if (users.isEmpty)
              Text(emptyMessage, key: emptyKey)
            else
              Column(
                children: users
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.small,
                        ),
                        child: _UserTile(
                          user: user,
                          enabled: !isSubmitting,
                          onSelectUser: onSelectUser,
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

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.enabled,
    required this.onSelectUser,
  });

  final UserProfile user;
  final bool enabled;
  final ValueChanged<UserProfile> onSelectUser;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: LoginKeys.user(user.id),
      contentPadding: EdgeInsets.zero,
      title: Text(user.displayName),
      subtitle: Text(user.id),
      trailing: const Icon(Icons.chevron_right),
      enabled: enabled,
      onTap: enabled ? () => onSelectUser(user) : null,
    );
  }
}

class _CreateUserSection extends StatelessWidget {
  const _CreateUserSection({
    required this.controller,
    required this.isSubmitting,
    required this.onCreateUser,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onCreateUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.loginCreateUserTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            TextField(
              key: LoginKeys.displayNameInput,
              controller: controller,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.loginDisplayNameLabel,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (!isSubmitting) {
                  onCreateUser();
                }
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            FilledButton(
              key: LoginKeys.createUserButton,
              onPressed: isSubmitting ? null : onCreateUser,
              child: Text(l10n.loginCreateUserButton),
            ),
          ],
        ),
      ),
    );
  }
}
