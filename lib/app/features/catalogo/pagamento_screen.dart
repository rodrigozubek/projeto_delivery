import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routing/routes.dart';
import '../../models/auth_model.dart';
import '../../models/cart_model.dart';
import '../../repositories/pedidos_repository.dart';
import '../../services/via_cep_service.dart';

class PagamentoScreen extends StatefulWidget {
  const PagamentoScreen({super.key});

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

enum TipoCartao { credito, debito, alimentacao }

class _PagamentoScreenState extends State<PagamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCartaoController = TextEditingController();
  final _numeroCVCController = TextEditingController();
  final _nomeTitularCartaoController = TextEditingController();
  final _dataValidadeCartaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroEnderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  static const _cameraChannel = MethodChannel('bebidasdelivery/native_camera');
  final _viaCepService = ViaCepService();

  TipoCartao? _tipoCartao;
  String? _fotoMaioridadePath;
  bool _isBuscandoCep = false;
  bool _isComprando = false;

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _numeroCVCController.dispose();
    _nomeTitularCartaoController.dispose();
    _dataValidadeCartaoController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroEnderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      _showMessage('Informe um CEP com 8 digitos.');
      return;
    }

    setState(() => _isBuscandoCep = true);

    try {
      final endereco = await _viaCepService.buscarEndereco(cep);
      if (!mounted) return;

      setState(() {
        _logradouroController.text = endereco.logradouro;
        _bairroController.text = endereco.bairro;
        _cidadeController.text = endereco.localidade;
        _ufController.text = endereco.uf;
      });
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isBuscandoCep = false);
      }
    }
  }

  Future<void> _tirarFotoMaioridade() async {
    try {
      final fotoPath = await _cameraChannel.invokeMethod<String>(
        'takeAgePhoto',
      );

      if (fotoPath != null && mounted) {
        setState(() => _fotoMaioridadePath = fotoPath);
      }
    } on MissingPluginException {
      if (mounted) {
        _showMessage('A camera esta disponivel na versao Android do app.');
      }
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(error.message ?? 'Nao foi possivel abrir a camera.');
      }
    }
  }

  Future<void> comprar() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartModel>();
    final possuiBebidaAlcoolica = cart.items.any((e) => e.bebida.isAlcoolica);
    if (possuiBebidaAlcoolica && _fotoMaioridadePath == null) {
      _showMessage('Anexe uma foto para confirmar maioridade.');
      return;
    }

    final auth = context.read<AuthModel>();
    final pedidosRepo = context.read<PedidosRepository>();
    final user = auth.currentUser;

    if (user == null) {
      context.go(AppRoutes.login);
      return;
    }

    if (cart.items.isEmpty) {
      _showMessage('Sua sacola esta vazia');
      context.go(AppRoutes.catalogo);
      return;
    }

    setState(() => _isComprando = true);

    try {
      final itensInput = cart.items
          .map(
            (e) => PedidoItemInput(
              idBebida: e.bebida.id,
              quantidade: e.quantity,
              precoUnitario: e.bebida.preco,
            ),
          )
          .toList();

      await pedidosRepo.cadastrarPedido(
        idUsuario: user.id,
        precoTotal: cart.total,
        itens: itensInput,
      );

      await cart.clear();

      if (mounted) {
        _showMessage('Compra realizada com sucesso');
        context.go(AppRoutes.catalogo);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Erro ao processar pedido: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isComprando = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final possuiBebidaAlcoolica = cart.items.any((e) => e.bebida.isAlcoolica);
    final totalItens = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F2),
        surfaceTintColor: Colors.transparent,
        title: const Text('Pagamento'),
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _OrderSummary(total: cart.total, itemCount: totalItens),
              const SizedBox(height: 14),
              _Section(
                icon: Icons.location_on_outlined,
                title: 'Entrega',
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TextInput(
                            controller: _cepController,
                            label: 'CEP',
                            icon: Icons.pin_drop_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CepInputFormatter(),
                            ],
                            validator: (value) {
                              final digits =
                                  value?.replaceAll(RegExp(r'\D'), '') ?? '';
                              if (digits.length != 8) {
                                return 'Informe o CEP';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _isBuscandoCep ? null : _buscarCep,
                            child: _isBuscandoCep
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.search),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TextInput(
                      controller: _logradouroController,
                      label: 'Rua',
                      icon: Icons.route_outlined,
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TextInput(
                            controller: _numeroEnderecoController,
                            label: 'Numero',
                            icon: Icons.home_outlined,
                            keyboardType: TextInputType.streetAddress,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TextInput(
                            controller: _bairroController,
                            label: 'Bairro',
                            icon: Icons.apartment_outlined,
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _TextInput(
                            controller: _cidadeController,
                            label: 'Cidade',
                            icon: Icons.location_city_outlined,
                            validator: _requiredValidator,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TextInput(
                            controller: _ufController,
                            label: 'UF',
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: _requiredValidator,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                icon: Icons.credit_card,
                title: 'Cartao',
                child: Column(
                  children: [
                    _TextInput(
                      controller: _numeroCartaoController,
                      label: 'Numero do cartao',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CartaoBancarioInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe um valor';
                        }
                        if (value.trim().length < 8) {
                          return 'Numero de cartao invalido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TextInput(
                            controller: _dataValidadeCartaoController,
                            label: 'Validade',
                            icon: Icons.event_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ValidadeCartaoInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe um valor';
                              }
                              if (value.trim().length < 4) {
                                return 'Digite a data corretamente';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TextInput(
                            controller: _numeroCVCController,
                            label: 'CVC',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe um valor';
                              }
                              if (value.trim().length < 3) {
                                return 'CVC invalido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TextInput(
                      controller: _nomeTitularCartaoController,
                      label: 'Nome do titular',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe um valor';
                        }
                        if (value.trim().length < 10) {
                          return 'O nome deve ter mais de 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    FormField<TipoCartao>(
                      initialValue: _tipoCartao,
                      validator: (valor) {
                        if (valor == null) {
                          return 'Selecione uma opcao de cartao';
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _PaymentTypeChip(
                                  label: 'Credito',
                                  icon: Icons.credit_card,
                                  selected: _tipoCartao == TipoCartao.credito,
                                  onSelected: () {
                                    setState(
                                      () => _tipoCartao = TipoCartao.credito,
                                    );
                                    state.didChange(TipoCartao.credito);
                                  },
                                ),
                                _PaymentTypeChip(
                                  label: 'Debito',
                                  icon: Icons.payments_outlined,
                                  selected: _tipoCartao == TipoCartao.debito,
                                  onSelected: () {
                                    setState(
                                      () => _tipoCartao = TipoCartao.debito,
                                    );
                                    state.didChange(TipoCartao.debito);
                                  },
                                ),
                                _PaymentTypeChip(
                                  label: 'Alimentacao',
                                  icon: Icons.restaurant_outlined,
                                  selected:
                                      _tipoCartao == TipoCartao.alimentacao,
                                  onSelected: () {
                                    setState(
                                      () => _tipoCartao =
                                          TipoCartao.alimentacao,
                                    );
                                    state.didChange(TipoCartao.alimentacao);
                                  },
                                ),
                              ],
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (possuiBebidaAlcoolica) ...[
                const SizedBox(height: 14),
                _Section(
                  icon: Icons.verified_user_outlined,
                  title: 'Maioridade',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFFE85D04)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Para bebidas alcoolicas, anexe uma foto de confirmacao antes de finalizar.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _tirarFotoMaioridade,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _fotoMaioridadePath == null
                              ? 'Tirar foto'
                              : 'Refazer foto',
                        ),
                      ),
                      if (_fotoMaioridadePath != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 220,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.file(
                            File(_fotoMaioridadePath!),
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final label = constraints.maxWidth < 360
                  ? 'Finalizar - R\$ ${cart.total.toStringAsFixed(2)}'
                  : 'Finalizar pedido - R\$ ${cart.total.toStringAsFixed(2)}';

              return FilledButton.icon(
                onPressed: _isComprando ? null : comprar,
                icon: _isComprando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe um valor';
    }
    return null;
  }
}

class _OrderSummary extends StatelessWidget {
  final double total;
  final int itemCount;

  const _OrderSummary({required this.total, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF212121),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} na sacola',
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
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

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFFE85D04), size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _TextInput({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: const Color(0xFFFBFAF8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _PaymentTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  const _PaymentTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: Icon(icon, size: 18),
      label: Text(label),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? const Color(0xFF8A3A00) : Colors.black87,
      ),
      selectedColor: const Color(0xFFFFE0B2),
      backgroundColor: const Color(0xFFFBFAF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
