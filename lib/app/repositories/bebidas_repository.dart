import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/bebida.dart';

class BebidasRepository {
  final AppDatabase appDatabase;

  BebidasRepository({required this.appDatabase});

  Future<List<Bebida>> loadBebidas() async {
    final db = await appDatabase.database;
    final rows = await db.query('bebidas', orderBy: 'nome ASC');
    return rows.map(Bebida.fromMap).toList();
  }

  Future<void> addBebida(Bebida bebida) async {
    final db = await appDatabase.database;
    final iguais = await db.query(
      'bebidas',
      where: 'LOWER(nome) = ?',
      whereArgs: [bebida.nome.toLowerCase()],
      limit: 1,
    );

    if (iguais.isNotEmpty) {
      throw Exception('Ja existe uma bebida com esse nome.');
    }

    await db.insert(
      'bebidas',
      bebida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
