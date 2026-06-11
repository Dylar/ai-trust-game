class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivityAt,
  });

  final String id;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;

  bool get isLoaded => lastActivityAt != null;
}
