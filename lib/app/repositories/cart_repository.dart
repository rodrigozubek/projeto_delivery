import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/bebida.dart';
import '../models/cart_entry.dart';

class CartRepository {
  final AppDatabase appDatabase;

  CartRepository({required this.appDatabase});

  Future<List<CartEntry>> loadItems() async {
    final db = await appDatabase.database;
    final rows = await db.rawQuery('''
      SELECT
        b.id,
        b.nome,
        b.descricao,
        b.preco,
        b.imagem_url,
        b.is_alcoolica,
        c.quantity
      FROM cart_items c
      INNER JOIN bebidas b ON b.id = c.bebida_id
      ORDER BY b.nome
    ''');

    return rows.map((row) {
      return CartEntry(
        bebida: Bebida.fromMap(row),
        quantity: row['quantity'] as int,
      );
    }).toList();
  }

  Future<void> saveItem(String bebidaId, int quantity) async {
    final db = await appDatabase.database;
    await db.insert('cart_items', {
      'bebida_id': bebidaId,
      'quantity': quantity,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeItem(String bebidaId) async {
    final db = await appDatabase.database;
    await db.delete(
      'cart_items',
      where: 'bebida_id = ?',
      whereArgs: [bebidaId],
    );
  }

  Future<void> clear() async {
    final db = await appDatabase.database;
    await db.delete('cart_items');
  }
}
