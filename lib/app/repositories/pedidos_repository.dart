import '../database/app_database.dart';
import '../models/pedido.dart';

class PedidosRepository {
  final AppDatabase appDatabase;

  PedidosRepository({required this.appDatabase});

  Future<void> cadastrarPedido({
    required int idUsuario,
    required double precoTotal,
    required List<PedidoItemInput> itens,
  }) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      // 1. Inserir o pedido principal
      final pedidoId = await txn.insert('pedidos', {
        'id_usuario': idUsuario,
        'preco_total': precoTotal,
        'data_pedido': DateTime.now().toIso8601String(),
      });

      // 2. Inserir todos os itens vinculados a este pedido
      for (final item in itens) {
        await txn.insert('pedido_items', {
          'id_pedido': pedidoId,
          'id_bebida': item.idBebida,
          'quantidade': item.quantidade,
          'preco_unitario': item.precoUnitario,
        });
      }
    });
  }

  Future<List<Pedido>> retornarPedidos({int? idUsuario}) async {
    final db = await appDatabase.database;

    // Buscar todos os pedidos com o nome do usuário
    final pedidosRows = await db.rawQuery('''
      SELECT 
        p.id,
        p.preco_total,
        u.nome as nome_usuario
      FROM pedidos p
      INNER JOIN users u ON p.id_usuario = u.id
      ${idUsuario == null ? '' : 'WHERE p.id_usuario = ?'}
      ORDER BY p.id DESC
    ''', idUsuario == null ? [] : [idUsuario]);

    List<Pedido> listaPedidos = [];

    for (final row in pedidosRows) {
      final pedidoId = row['id'] as int;

      // Buscar os itens deste pedido específico
      final itensRows = await db.rawQuery('''
        SELECT 
          pi.quantidade,
          pi.preco_unitario,
          b.nome as nome_bebida
        FROM pedido_items pi
        INNER JOIN bebidas b ON pi.id_bebida = b.id
        WHERE pi.id_pedido = ?
      ''', [pedidoId]);

      final itens = itensRows.map((itemRow) {
        return PedidoItem(
          nomeBebida: itemRow['nome_bebida'] as String,
          quantidade: itemRow['quantidade'] as int,
          precoUnitario: (itemRow['preco_unitario'] as num).toDouble(),
        );
      }).toList();

      listaPedidos.add(Pedido(
        id: pedidoId,
        nomeUsuario: row['nome_usuario'] as String,
        precoTotal: (row['preco_total'] as num).toDouble(),
        itens: itens,
      ));
    }

    return listaPedidos;
  }
}

class PedidoItemInput {
  final String idBebida;
  final int quantidade;
  final double precoUnitario;

  PedidoItemInput({
    required this.idBebida,
    required this.quantidade,
    required this.precoUnitario,
  });
}
