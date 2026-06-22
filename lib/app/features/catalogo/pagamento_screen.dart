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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F2),
        surfaceTintColor: Colors.transparent,
        title: const Text('Pagamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text(
              'Entrega',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cepController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CEP',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CepInputFormatter(),
                    ],
                    validator: (value) {
                      final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                      if (digits.length != 8) {
                        return 'Informe o CEP';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isBuscandoCep ? null : _buscarCep,
                    icon: _isBuscandoCep
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _logradouroController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Rua',
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroEnderecoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numero',
              ),
              keyboardType: TextInputType.streetAddress,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bairroController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Bairro',
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cidadeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Cidade',
                    ),
                    validator: _requiredValidator,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _ufController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'UF',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [LengthLimitingTextInputFormatter(2)],
                    validator: _requiredValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Cartao',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroCartaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numero do cartao',
              ),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroCVCController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CVC',
              ),
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
                  return 'Numero digitado menor do que 3';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataValidadeCartaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Data de validade',
              ),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeTitularCartaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome do titular',
              ),
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
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
            const SizedBox(height: 16),
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
                    RadioListTile<TipoCartao>(
                      title: const Text('Credito'),
                      value: TipoCartao.credito,
                      // ignore: deprecated_member_use
                      groupValue: _tipoCartao,
                      // ignore: deprecated_member_use
                      onChanged: (valor) {
                        setState(() => _tipoCartao = valor);
                        state.didChange(valor);
                      },
                    ),
                    RadioListTile<TipoCartao>(
                      title: const Text('Debito'),
                      value: TipoCartao.debito,
                      // ignore: deprecated_member_use
                      groupValue: _tipoCartao,
                      // ignore: deprecated_member_use
                      onChanged: (valor) {
                        setState(() => _tipoCartao = valor);
                        state.didChange(valor);
                      },
                    ),
                    RadioListTile<TipoCartao>(
                      title: const Text('Alimentacao'),
                      value: TipoCartao.alimentacao,
                      // ignore: deprecated_member_use
                      groupValue: _tipoCartao,
                      // ignore: deprecated_member_use
                      onChanged: (valor) {
                        setState(() => _tipoCartao = valor);
                        state.didChange(valor);
                      },
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
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
            if (possuiBebidaAlcoolica) ...[
              const SizedBox(height: 24),
              const Text(
                'Confirmacao de maioridade',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _tirarFotoMaioridade,
                icon: const Icon(Icons.photo_camera),
                label: Text(
                  _fotoMaioridadePath == null ? 'Tirar foto' : 'Refazer foto',
                ),
              ),
              if (_fotoMaioridadePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_fotoMaioridadePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isComprando ? null : comprar,
              icon: _isComprando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payment),
              label: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Comprar'),
              ),
            ),
          ],
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
