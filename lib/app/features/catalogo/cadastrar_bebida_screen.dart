import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'catalogo_viewmodel.dart';

class CadastrarBebidaScreen extends StatefulWidget {
  const CadastrarBebidaScreen({super.key});

  @override
  State<CadastrarBebidaScreen> createState() => _CadastrarBebidaScreenState();
}

class _CadastrarBebidaScreenState extends State<CadastrarBebidaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  bool _isAlcoolica = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CatalogoViewModel>();
    final success = await vm.saveBebida(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim(),
      precoText: _precoController.text.trim(),
      isAlcoolica: _isAlcoolica,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Erro ao cadastrar bebida'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bebida cadastrada com sucesso')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F2),
        surfaceTintColor: Colors.transparent,
        title: const Text('Cadastrar Bebida'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Preencha os campos para adicionar uma nova bebida ao catalogo.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _FormCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: _inputDecoration(
                      label: 'Nome da bebida',
                      icon: Icons.local_drink,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome da bebida';
                      }
                      if (value.trim().length < 3) {
                        return 'O nome deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descricaoController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      label: 'Descricao',
                      icon: Icons.notes,
                    ).copyWith(alignLabelWithHint: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe uma descricao';
                      }
                      if (value.trim().length < 10) {
                        return 'A descricao deve ter pelo menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration(
                      label: 'Preco',
                      icon: Icons.attach_money,
                    ).copyWith(prefixText: 'R\$ '),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o preco';
                      }
                      final preco = double.tryParse(value.replaceAll(',', '.'));
                      if (preco == null) {
                        return 'Digite um preco valido';
                      }
                      if (preco <= 0) {
                        return 'O preco deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: _isAlcoolica,
                      title: const Text('Bebida alcoolica'),
                      subtitle: const Text('Marque se o produto contem alcool'),
                      onChanged: (value) {
                        setState(() {
                          _isAlcoolica = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: vm.isSaving ? null : _salvar,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE85D04),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: vm.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(vm.isSaving ? 'Salvando...' : 'Salvar bebida'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;

  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
