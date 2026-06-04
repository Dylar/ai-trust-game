enum Role { guest, employee, admin }

enum Mode { easy, medium, hard }

class Session {
  const Session({required this.id, required this.role, required this.mode});

  final String id;
  final Role role;
  final Mode mode;
}
