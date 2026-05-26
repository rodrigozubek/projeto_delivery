enum UserRole {
  admin,
  comprador;

  static UserRole fromDatabase(String? value) {
    return switch (value) {
      'admin' => UserRole.admin,
      _ => UserRole.comprador,
    };
  }

  String get databaseValue {
    return switch (this) {
      UserRole.admin => 'admin',
      UserRole.comprador => 'comprador',
    };
  }
}

class AppUser {
  final int id;
  final String nome;
  final String email;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.nome,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: (map['id'] as num).toInt(),
      nome: map['nome'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      role: UserRole.fromDatabase(map['role'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password_hash': passwordHash,
      'role': role.databaseValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
