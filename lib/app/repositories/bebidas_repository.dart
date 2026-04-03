import 'dart:collection';

import '../models/bebida.dart';

class BebidasRepository {
  final List<Bebida> _bebidas = [
    Bebida(
      id: '1',
      nome: 'Cerveja Artesanal IPA',
      descricao: '500ml - Notas citricas e amargor moderado.',
      preco: 18.90,
      imagemUrl: 'assets/images/ipa.png',
      isAlcoolica: true,
    ),
    Bebida(
      id: '2',
      nome: 'Suco de Laranja Natural',
      descricao: '400ml - Sem adicao de acucar.',
      preco: 9.50,
      imagemUrl: 'assets/images/suco.png',
      isAlcoolica: false,
    ),
  ];

  UnmodifiableListView<Bebida> get bebidas => UnmodifiableListView(_bebidas);

  List<Bebida> loadBebidas() {
    return bebidas;
  }
}
