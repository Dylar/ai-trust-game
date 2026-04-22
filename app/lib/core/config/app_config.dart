import 'package:app/core/config/app_flavor.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUri, required this.flavor});

  factory AppConfig.fromEnvironment() {
    const flavorName = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'dev',
    );

    return AppConfig(
      apiBaseUri: Uri.parse(
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080',
        ),
      ),
      flavor: AppFlavor.fromName(flavorName),
    );
  }

  final Uri apiBaseUri;
  final AppFlavor flavor;
}
