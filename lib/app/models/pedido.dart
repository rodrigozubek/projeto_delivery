import 'bebida.dart';

class Pedido {
  final int? id;
  final String nomeUsuario;
  final List<PedidoItem> itens;
  final double precoTotal;

  Pedido({
    this.id,
    required this.nomeUsuario,
    required this.itens,
    required this.precoTotal,
  });
}

class PedidoItem {
  final String nomeBebida;
  final int quantidade;
  final double precoUnitario;

  PedidoItem({
    required this.nomeBebida,
    required this.quantidade,
    required this.precoUnitario,
  });
}
