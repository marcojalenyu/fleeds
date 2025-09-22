class User {
  final String id;
  String username;
  String password;
  String displayName;
  final DateTime createdAt;
  DateTime? updatedAt;

  User({
    required this.id,
    this.username = '',
    this.password = '',
    this.displayName = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}