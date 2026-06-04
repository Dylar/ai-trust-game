import 'package:flutter/material.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_spacing.dart';

Future<void> showAppErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        backgroundColor: AppColors.errorSurface,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.small),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message, style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      );
    },
  );
}
