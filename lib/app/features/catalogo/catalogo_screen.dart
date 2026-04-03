import 'package:flutter/material.dart';

import '../../models/bebida.dart';
import '../../repositories/bebidas_repository.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late final BebidasRepository bebidasRepository;
  List<Bebida> bebidas = [];

  @override
  void initState() {
    super.initState();
    bebidasRepository = BebidasRepository();
    bebidas = bebidasRepository.loadBebidas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebidas Disponiveis'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: ListView.separated(
        itemCount: bebidas.length,
        itemBuilder: (context, index) {
          final bebida = bebidas[index];

          return ListTile(
            leading: Image.asset(
              bebida.imagemUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.local_drink, color: Colors.grey),
            ),
            title: Text(
              bebida.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(bebida.descricao),
            trailing: Text(
              'R\$ ${bebida.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${bebida.nome} selecionado')),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.amber,
        child: const Icon(Icons.shopping_cart, color: Colors.black),
      ),
    );
  }
}
