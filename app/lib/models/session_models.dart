enum Role { guest, employee, admin }

enum Mode { easy, medium, hard }

class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.role,
    required this.mode,
    required this.lastMessagePreview,
  });

  final String id;
  final Role role;
  final Mode mode;
  final String lastMessagePreview;
}
