class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const User({required this.id, required this.name, required this.email, this.avatarUrl});

  factory User.fromMap(String id, Map<String, dynamic> map) => User(
        id: id,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      };
}
