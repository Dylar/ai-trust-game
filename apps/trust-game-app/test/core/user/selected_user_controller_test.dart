import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GIVEN no selected user WHEN required THEN throws state error', () {
    final controller = SelectedUserController();

    expect(() => controller.requiredUser, throwsStateError);
  });

  test('GIVEN selected user WHEN changed THEN listeners see the new user', () {
    final controller = SelectedUserController();
    final seen = <String?>[];
    controller.addListener(() {
      seen.add(controller.value?.id);
    });

    controller.select(const UserIdentity(id: 'user-1'));
    controller.clear();

    expect(seen, <String?>['user-1', null]);
  });
}
