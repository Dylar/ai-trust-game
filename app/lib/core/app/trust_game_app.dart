import 'package:flutter/material.dart';

import '../../screens/session_start/session_start_screen.dart';
import '../theme/app_theme.dart';

class TrustGameApp extends StatelessWidget {
  const TrustGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Trust Game',
      theme: buildAppTheme(),
      home: const SessionStartScreen(),
    );
  }
}
