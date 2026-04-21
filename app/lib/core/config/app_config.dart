class AppConfig {
  const AppConfig({required this.apiBaseUri});

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUri: Uri.parse(
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080',
        ),
      ),
    );
  }

  final Uri apiBaseUri;
}
