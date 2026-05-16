class AppUser {
  final String id;
  final String nome;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as String,
      nome: map['nome'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
