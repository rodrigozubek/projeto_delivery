import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routing/routes.dart';
import '../../models/auth_model.dart';
import '../../models/bebida.dart';
import '../../models/cart_model.dart';
import 'catalogo_viewmodel.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late final CatalogoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CatalogoViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.addListener(_handleFeedback);
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleFeedback);
    super.dispose();
  }

  void _handleFeedback() {
    if (_viewModel.feedback.isEmpty || !mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.feedback),
        duration: const Duration(seconds: 2),
      ),
    );
    _viewModel.clearFeedback();
  }

  Future<void> _sair() async {
    final cart = context.read<CartModel>();
    await cart.clear();
    if (!mounted) return;
    await context.read<AuthModel>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogoViewModel>();
    final cart = context.watch<CartModel>();
    final auth = context.watch<AuthModel>();
    final totalItens = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.pedidos),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Meus pedidos',
          ),
          if (auth.isAdmin)
            IconButton(
              onPressed: () => context.push(AppRoutes.cadastrarBebida),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Cadastrar bebida',
            ),
          IconButton(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: vm.isLoading
            ? const _LoadingState()
            : vm.errorMessage != null && vm.bebidas.isEmpty
                ? _ErrorState(message: vm.errorMessage!, onRetry: vm.load)
                : ListView.separated(
                    key: const ValueKey('catalogo-list'),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      cart.itemCount > 0 ? 126 : 24,
                    ),
                    itemCount: vm.bebidas.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _CatalogHeader(
                          userName: auth.currentUser?.nome ?? 'Cliente',
                          itemCount: vm.bebidas.length,
                          totalCartItems: totalItens,
                        );
                      }

                      final bebida = vm.bebidas[index - 1];
                      return _BebidaCard(
                        bebida: bebida,
                        onAdd: () => vm.addToCart(bebida),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: cart.itemCount == 0
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
                  onPressed: () => context.push(AppRoutes.sacola),
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Ver sacola - R\$ ${cart.total.toStringAsFixed(2)}',
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

class _CatalogHeader extends StatelessWidget {
  final String userName;
  final int itemCount;
  final int totalCartItems;

  const _CatalogHeader({
    required this.userName,
    required this.itemCount,
    required this.totalCartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF212121),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE85D04),
                  child: Icon(Icons.local_bar, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ola, $userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Escolha suas bebidas e finalize o pedido com entrega por CEP.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderChip(
                  icon: Icons.storefront_outlined,
                  label: '$itemCount bebidas',
                ),
                _HeaderChip(
                  icon: Icons.shopping_bag_outlined,
                  label: '$totalCartItems na sacola',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BebidaCard extends StatelessWidget {
  final Bebida bebida;
  final VoidCallback onAdd;

  const _BebidaCard({required this.bebida, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 86,
                  height: 96,
                  child: Image.asset(
                    bebida.imagemUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFFFEFE2),
                      child: const Icon(
                        Icons.local_drink,
                        color: Color(0xFFE85D04),
                        size: 34,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            bebida.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (bebida.isAlcoolica)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEFE2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '18+',
                              style: TextStyle(
                                color: Color(0xFFE85D04),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      bebida.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'R\$ ${bebida.preco.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar'),
                        ),
                      ],
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Carregando catalogo...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
