import '../database/app_database.dart';

class PedidosRepository {
  final AppDatabase appDatabase;

  PedidosRepository({required this.appDatabase});

  Future<void> cadastrarPedido({
    required String idBebida,
    required String idUsuario,
    required double precoTotal,
    required int quantidade,
  }) async {
    final db = await appDatabase.database;
    await db.insert('pedidos', {
      'id_bebida': idBebida,
      'id_usuario': idUsuario,
      'preco_total': precoTotal,
      'quantidade': quantidade,
    });
  }

  Future<List<Map<String, dynamic>>> retornarPedidos() async {
    final db = await appDatabase.database;
    return await db.rawQuery('''
      SELECT 
        p.id,
        b.nome as nome_bebida,
        u.nome as nome_usuario,
        p.preco_total,
        p.quantidade
      FROM pedidos p
      INNER JOIN bebidas b ON p.id_bebida = b.id
      INNER JOIN users u ON p.id_usuario = u.id
      ORDER BY p.id DESC
    ''');
  }
}
