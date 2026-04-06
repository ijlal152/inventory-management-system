class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
