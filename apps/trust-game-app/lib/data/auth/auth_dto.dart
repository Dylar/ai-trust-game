import 'package:app/core/user/user_profile.dart';

class AuthUserResponse {
  const AuthUserResponse({
    required this.userId,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthUserResponse.fromJson(Map<String, dynamic> json) {
    return AuthUserResponse(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String userId;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile toUserProfile() {
    return UserProfile(
      id: userId,
      displayName: displayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ListAuthUsersResponse {
  const ListAuthUsersResponse({required this.users});

  factory ListAuthUsersResponse.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as List<dynamic>;
    return ListAuthUsersResponse(
      users: users
          .cast<Map<String, dynamic>>()
          .map(AuthUserResponse.fromJson)
          .toList(),
    );
  }

  final List<AuthUserResponse> users;
}

class CreateAuthUserRequest {
  const CreateAuthUserRequest({required this.displayName});

  final String displayName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'displayName': displayName};
  }
}
