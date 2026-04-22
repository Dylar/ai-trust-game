import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to dev flavor and localhost backend', () {
    final config = AppConfig.fromEnvironment();

    expect(config.flavor, AppFlavor.dev);
    expect(config.apiBaseUri, Uri.parse('http://localhost:8080'));
  });

  test('parses known flavor names', () {
    expect(AppFlavor.fromName('dev'), AppFlavor.dev);
    expect(AppFlavor.fromName('test'), AppFlavor.test);
    expect(AppFlavor.fromName('prod'), AppFlavor.prod);
  });

  test('falls back to dev for unknown flavor names', () {
    expect(AppFlavor.fromName('unknown'), AppFlavor.dev);
  });
}
