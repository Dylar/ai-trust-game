import 'package:flutter/material.dart';

class AppBarLoadingIndicator extends StatelessWidget {
  const AppBarLoadingIndicator({
    required this.isRefreshing,
    required this.indicatorKey,
    super.key,
  });

  final bool isRefreshing;
  final Key indicatorKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: isRefreshing
            ? SizedBox(
                key: indicatorKey,
                width: 18,
                height: 18,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
