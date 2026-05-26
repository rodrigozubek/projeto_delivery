import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/auth_model.dart';
import '../../models/cart_model.dart';
import '../../repositories/pedidos_repository.dart';
import '../../../routing/routes.dart';

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
  TipoCartao? _tipoCartao;

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _numeroCVCController.dispose();
    _nomeTitularCartaoController.dispose();
    _dataValidadeCartaoController.dispose();
    super.dispose();
  }

  Future<void> comprar() async {
    if (_formKey.currentState!.validate()) {
      final cart = context.read<CartModel>();
      final auth = context.read<AuthModel>();
      final pedidosRepo = context.read<PedidosRepository>();

      final user = auth.currentUser;
      if (user == null) {
        context.go(AppRoutes.login);
        return;
      }

      if (cart.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sua sacola esta vazia')),
        );
        context.go(AppRoutes.catalogo);
        return;
      }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compra realizada com sucesso')),
          );
          context.go(AppRoutes.catalogo);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao processar pedido: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.all(12),
          children: [
            Text(
              'Insira os dados do seu cartão',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _numeroCartaoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'numero do cartao' ,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CartaoBancarioInputFormatter(),
                ],
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'informe um valor';
                }
                if (value.trim().length < 8) {
                  return 'Numero de cartão invalido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _numeroCVCController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'numero cvc do cartao' ,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                ],
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'informe um valor';
                }
                if (value.trim().length < 3) {
                  return 'numero digitado menor do que 3';
                }
                return null;
              },
            ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _dataValidadeCartaoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'data de validade' ,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ValidadeCartaoInputFormatter(),
                ],
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'informe um valor';
                }
                if (value.trim().length < 4) {
                  return 'digite a data corretamente';
                }
                return null;
              },
            ),
            const SizedBox(height: 16,),
            TextFormField(
              controller: _nomeTitularCartaoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome do titular do cartao' ,
              ),
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Zá-úÁ-Úâ-ûÂ-ÛãõÃÕçÇ\s]'
                  ),
            ),
                ],
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'informe um valor';
                }
                if (value.trim().length < 10) {
                  return 'O nome deve ter mais de 10 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16,),
            FormField<TipoCartao>(
              initialValue: _tipoCartao,
              validator: (valor) {
                if (valor == null) {
                  return 'Por favor, selecione uma opção de cartão';
                }
                return null;
              },
              builder: (FormFieldState<TipoCartao> state){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  RadioListTile<TipoCartao>(
                    title: const Text('Credito'),
                    value: TipoCartao.credito, // O valor DESTE botão
                    // ignore: deprecated_member_use
                    groupValue: _tipoCartao,  // O valor SELECIONADO atualmente
                    // ignore: deprecated_member_use
                    onChanged: (TipoCartao? valor) {
                      setState(() {
                        _tipoCartao = valor;
                      });
                      state.didChange(valor);
                    },
                  ),
                  RadioListTile<TipoCartao>(
                    title: const Text('Debito'),
                    value: TipoCartao.debito, // O valor DESTE botão
                    // ignore: deprecated_member_use
                    groupValue: _tipoCartao,  // O valor SELECIONADO atualmente
                    // ignore: deprecated_member_use
                    onChanged: (TipoCartao? valor) {
                      setState(() {
                        _tipoCartao = valor;
                      });
                      state.didChange(valor);
                    },
                  ),
                RadioListTile<TipoCartao>(
                  title: const Text('Alimentação'),
                  value: TipoCartao.alimentacao, // O valor DESTE botão
                  // ignore: deprecated_member_use
                  groupValue: _tipoCartao,  // O valor SELECIONADO atualmente
                  // ignore: deprecated_member_use
                  onChanged: (TipoCartao? valor) {
                    setState(() {
                      _tipoCartao = valor;
                    });
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
                  )
                ],
              );
              }
            ),
            const SizedBox(height: 24,),
            ElevatedButton(
              onPressed: comprar, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Comprar'),
                  )
                ],
              )
            )
          ],
        ) 
      ),
    );
  }
}
