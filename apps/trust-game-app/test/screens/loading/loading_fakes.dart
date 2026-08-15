import 'package:app/core/user/user_profile.dart';
import 'package:app/data/auth/auth_api_client.dart';

class FakeLoadingAuthApi implements AuthApi {
  const FakeLoadingAuthApi({this.shouldFailLoad = false});

  final bool shouldFailLoad;

  @override
  Future<UserProfile> createUser(String displayName) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserProfile>> listUsers() async {
    if (shouldFailLoad) {
      throw Exception('load failed');
    }
    return const <UserProfile>[];
  }
}
