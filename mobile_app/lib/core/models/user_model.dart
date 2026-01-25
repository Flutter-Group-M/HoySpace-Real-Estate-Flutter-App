class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'user',
    );
  }
}
