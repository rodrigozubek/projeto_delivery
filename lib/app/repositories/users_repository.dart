import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/app_user.dart';

class UsersRepository {
  final AppDatabase appDatabase;

  UsersRepository({required this.appDatabase});

  Future<AppUser> createUser({
    required String nome,
    required String email,
    required String password,
    UserRole role = UserRole.comprador,
  }) async {
    final db = await appDatabase.database;
    final normalizedEmail = email.trim().toLowerCase();
    final createdAt = DateTime.now();
    final passwordHash = _hashPassword(password);

    try {
      final userId = await db.insert('users', {
        'nome': nome.trim(),
        'email': normalizedEmail,
        'password_hash': passwordHash,
        'role': role.databaseValue,
        'created_at': createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      return AppUser(
        id: userId,
        nome: nome.trim(),
        email: normalizedEmail,
        passwordHash: passwordHash,
        role: role,
        createdAt: createdAt,
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw Exception('Ja existe um usuario cadastrado com esse email.');
      }
      rethrow;
    }
  }

  Future<AppUser?> findByEmail(String email) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await appDatabase.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> validateLogin({
    required String email,
    required String password,
  }) async {
    final user = await findByEmail(email);
    if (user == null) return null;

    final passwordHash = _hashPassword(password);
    if (user.passwordHash != passwordHash) return null;

    return user;
  }

  Future<void> saveCurrentUser(AppUser user) async {
    final db = await appDatabase.database;
    await db.insert('app_session', {
      'id': 1,
      'user_id': user.id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> loadCurrentUser() async {
    final db = await appDatabase.database;
    final rows = await db.query('app_session', where: 'id = ?', whereArgs: [1]);

    if (rows.isEmpty) return null;

    final userId = (rows.first['user_id'] as num).toInt();
    final user = await findById(userId);
    if (user == null) {
      await clearCurrentUser();
    }

    return user;
  }

  Future<void> clearCurrentUser() async {
    final db = await appDatabase.database;
    await db.delete('app_session', where: 'id = ?', whereArgs: [1]);
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
