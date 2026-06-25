import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth_model.dart';
import '../../models/pedido.dart';
import '../../repositories/pedidos_repository.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthModel>().currentUser;
    _pedidosFuture = context.read<PedidosRepository>().retornarPedidos(
      idUsuario: user?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus pedidos')),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: 'Nao foi possivel carregar',
              message: '${snapshot.error}',
            );
          }

          final pedidos = snapshot.data ?? [];

          if (pedidos.isEmpty) {
            return const _MessageState(
              icon: Icons.receipt_long_outlined,
              title: 'Nenhum pedido ainda',
              message: 'Quando voce finalizar uma compra, ela aparece aqui.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: pedidos.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _PedidosHeader(count: pedidos.length);
              }

              return _PedidoCard(pedido: pedidos[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _PedidosHeader extends StatelessWidget {
  final int count;

  const _PedidosHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF212121),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE85D04),
              child: Icon(Icons.receipt_long, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count pedido${count == 1 ? '' : 's'} realizado${count == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;

  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFFE85D04),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${pedido.id}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Cliente: ${pedido.nomeUsuario}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${pedido.precoTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...pedido.itens.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFE2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantidade}x',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.nomeBebida)),
                    Text(
                      'R\$ ${(item.precoUnitario * item.quantidade).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 42, color: const Color(0xFFE85D04)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
