import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/cart_model.dart';
import '../../routes.dart';
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
        action: SnackBarAction(
          label: 'Ver sacola',
          onPressed: _abrirSacola,
        ),
      ),
    );
    _viewModel.clearFeedback();
  }

  void _abrirSacola() {
    context.push(AppRoutes.sacola);
  }

  void _abrirCadastro() {
    context.push(AppRoutes.cadastrarBebida);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogoViewModel>();
    final cart = context.watch<CartModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F2),
        surfaceTintColor: Colors.transparent,
        title: const Text('Catálogo de Bebidas'),
        actions: [
          IconButton(
            onPressed: _abrirCadastro,
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar bebida',
          ),
          Stack(
            children: [
              IconButton(
                onPressed: _abrirSacola,
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Abrir sacola',
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: const Color(0xFFE85D04),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Bebidas disponiveis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${vm.bebidas.length} itens',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: vm.isLoading
                  ? const Center(
                      key: ValueKey('loading'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Carregando catalogo...'),
                        ],
                      ),
                    )
                  : vm.errorMessage != null && vm.bebidas.isEmpty
                  ? Center(
                      key: const ValueKey('error'),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            Text(vm.errorMessage!),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: vm.load,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: vm.bebidas.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final bebida = vm.bebidas[index];

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => vm.addToCart(bebida),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 72,
                                      height: 72,
                                      child: Image.asset(
                                        bebida.imagemUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.local_drink,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                bebida.nome,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (bebida.isAlcoolica)
                                              const Text(
                                                '18+',
                                                style: TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          bebida.descricao,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              'R\$ ${bebida.preco.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            OutlinedButton(
                                              onPressed:
                                                  () => vm.addToCart(bebida),
                                              child: const Text('Adicionar'),
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
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirSacola,
        backgroundColor: const Color(0xFFE85D04),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.shopping_cart),
        label: Text(
          cart.itemCount == 0 ? 'Sacola' : 'Sacola (${cart.itemCount})',
        ),
      ),
    );
  }
}
