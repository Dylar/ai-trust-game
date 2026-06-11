import 'package:flutter/material.dart';

void main() {
  runApp(const AuthBootstrapPlaceholderApp());
}

class AuthBootstrapPlaceholderApp extends StatelessWidget {
  const AuthBootstrapPlaceholderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('User selection required'))),
    );
  }
}
