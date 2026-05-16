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
  }) async {
    final db = await appDatabase.database;
    final normalizedEmail = email.trim().toLowerCase();
    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    try {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return user;
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

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
