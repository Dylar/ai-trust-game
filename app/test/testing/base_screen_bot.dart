import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BaseScreenBot {
  BaseScreenBot(this.tester);

  final WidgetTester tester;

  Finder getFinder(dynamic target) {
    return switch (target) {
      Finder finder => finder,
      Key key => find.byKey(key),
      String value => find.byKey(Key(value)),
      _ => throw ArgumentError('Unsupported finder target: $target'),
    };
  }

  bool isVisible(dynamic target) {
    return getFinder(target).evaluate().isNotEmpty;
  }

  Future<void> tap(dynamic target) async {
    final finder = getFinder(target);
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> enterText(dynamic target, String text) async {
    final finder = getFinder(target);
    await tester.tap(finder);
    await tester.pump();
    await tester.enterText(finder, text);
    await tester.pump();
  }

  Future<void> scrollUntilVisible(
    dynamic target, {
    double delta = 200,
    Finder? scrollable,
  }) async {
    await tester.scrollUntilVisible(
      getFinder(target),
      delta,
      scrollable: scrollable ?? find.byType(Scrollable).first,
    );
  }

  Future<void> pump(Duration duration) async {
    await tester.pump(duration);
  }
}
