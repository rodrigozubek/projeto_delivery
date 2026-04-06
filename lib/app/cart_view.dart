import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  Widget _buildBadgeAlcoholic(bool isAlcoolica) {
    if (!isAlcoolica) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(12)),
      child: const Text('Álcool', style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final entries = cart.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: entries.isEmpty ? null : () => cart.clear(),
          )
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text('Sua sacola está vazia', style: TextStyle(fontSize: 16)),
              ]),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (ctx, i) {
                final entry = entries[i];
                final b = entry.bebida;
                return Dismissible(
                  key: ValueKey(b.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => cart.remove(b.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 84,
                            height: 84,
                            child: Image.network(
                              b.imagemUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.local_drink, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(b.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                              _buildBadgeAlcoholic(b.isAlcoolica),
                            ]),
                            const SizedBox(height: 6),
                            Text(b.descricao, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('R\$ ${b.preco.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text('Subtotal R\$ ${(b.preco * entry.quantity).toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                            ]),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        Column(children: [
                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => cart.changeQuantity(b.id, 1)),
                          Text('${entry.quantity}', style: const TextStyle(fontSize: 16)),
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => cart.changeQuantity(b.id, -1)),
                        ]),
                      ]),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text('R\$ ${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Finalizar'),
              onPressed: entries.isEmpty
                  ? null
                  : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ...entries.map((e) => Text('${e.quantity} x ${e.bebida.nome} — R\$ ${(e.bebida.preco * e.quantity).toStringAsFixed(2)}')),
                            const SizedBox(height: 12),
                            Text('Total R\$ ${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                cart.clear();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout simulado')));
                              },
                              child: const Center(child: Text('Confirmar pagamento')),
                            ),
                          ]),
                        ),
                      );
                    },
            ),
          ]),
        ),
      ),
    );
  }
}