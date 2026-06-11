import 'package:flutter/material.dart';

import 'package:app/core/theme/app_spacing.dart';
import 'package:app/screens/loading/loading_keys.dart';
import 'package:app/screens/loading/loading_screen_state.dart';
import 'package:app/screens/loading/loading_view_model.dart';
import 'package:app/services/startup_refresh_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.viewModel,
    required this.onLoaded,
  });

  final LoadingViewModel viewModel;
  final ValueChanged<StartupRefreshResult> onLoaded;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    final result = await widget.viewModel.load();
    if (!mounted) {
      return;
    }
    widget.onLoaded(result);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: LoadingKeys.screen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ValueListenableBuilder<LoadingScreenState>(
              valueListenable: widget.viewModel.state,
              builder: (context, state, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.status == LoadingScreenStatus.loading) ...[
                      const CircularProgressIndicator(
                        key: LoadingKeys.loadingIndicator,
                      ),
                      const SizedBox(height: AppSpacing.large),
                    ],
                    Text(
                      state.message,
                      key: LoadingKeys.statusMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
