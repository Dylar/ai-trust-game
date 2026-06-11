import 'package:flutter/material.dart';

import 'core/app/app_dependencies.dart';
import 'core/app/trust_game_app.dart';
import 'core/routing/app_router.dart';

void main() {
  final dependencies = AppDependencies.defaults();
  final router = AppRouter(dependencies: dependencies);
  runApp(TrustGameApp(router: router));
}
