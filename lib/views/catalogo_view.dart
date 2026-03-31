import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/bebida_controller.dart';

class CatalogoView extends StatelessWidget {
  const CatalogoView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BebidaController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebidas Disponíveis'),
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        itemCount: controller.produtos.length,
        itemBuilder: (context, index) {
          final bebida = controller.produtos[index];
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Image.asset(
                bebida.imagemUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.grey),
              ),
              
              title: Text(bebida.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(bebida.descricao),

              trailing: Text(
                'R\$ ${bebida.preco.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${bebida.nome} selecionado')),
                );
              },
            ),
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.amber,
        child: const Icon(Icons.shopping_cart, color: Colors.black),
      ),
    );
  }
}