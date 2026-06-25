import 'package:bebidasdelivery/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/cart_entry.dart';
import '../../models/cart_model.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final entries = cart.items;
    final totalItens = entries.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpar sacola',
            onPressed: entries.isEmpty ? null : () async => cart.clear(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const _EmptyCart()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 126),
                  itemCount: entries.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CartSummary(
                        total: cart.total,
                        itemCount: totalItens,
                      );
                    }

                    final entry = entries[index - 1];
                    return _CartItemCard(entry: entry, cart: cart);
                  },
                ),
      bottomNavigationBar: entries.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F6F2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.pagamento),
                  icon: const Icon(Icons.payment),
                  label: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Ir para pagamento - R\$ ${cart.total.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final int itemCount;

  const _CartSummary({required this.total, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF212121),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} selecionado${itemCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartEntry entry;
  final CartModel cart;

  const _CartItemCard({required this.entry, required this.cart});

  @override
  Widget build(BuildContext context) {
    final bebida = entry.bebida;

    return Dismissible(
      key: ValueKey(bebida.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async => cart.remove(bebida.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: Image.asset(
                    bebida.imagemUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFFFEFE2),
                      child: const Icon(
                        Icons.local_drink,
                        color: Color(0xFFE85D04),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bebida.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'R\$ ${bebida.preco.toStringAsFixed(2)} cada',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subtotal R\$ ${(bebida.preco * entry.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async => cart.changeQuantity(bebida.id, 1),
                    ),
                    Text(
                      '${entry.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () async => cart.changeQuantity(bebida.id, -1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFE2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 44,
                color: Color(0xFFE85D04),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sua sacola esta vazia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Adicione bebidas do catalogo para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Voltar ao catalogo'),
            ),
          ],
        ),
      ),
    );
  }
}
