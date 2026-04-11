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
    Bebida(
    id: '3',
    nome: 'Cerveja Pilsen',
    descricao: '350ml - Leve e refrescante.',
    preco: 6.90,
    imagemUrl: 'assets/images/pilsen.png',
    isAlcoolica: true,
  ),

  Bebida(
    id: '4',
    nome: 'Cerveja Weiss',
    descricao: '500ml - Notas de banana e cravo.',
    preco: 15.90,
    imagemUrl: 'assets/images/weiss.png',
    isAlcoolica: true,
  ),

  Bebida(
    id: '5',
    nome: 'Cerveja Lager Premium',
    descricao: '600ml - Sabor suave e equilibrado.',
    preco: 12.90,
    imagemUrl: 'assets/images/lager.png',
    isAlcoolica: true,
  ),
  Bebida(
    id: '6',
    nome: 'Caipirinha Tradicional',
    descricao: 'Limão + cachaça + gelo.',
    preco: 14.90,
    imagemUrl: 'assets/images/caipirinha.png',
    isAlcoolica: true,
  ),
  Bebida(
    id: '7',
    nome: 'Mojito',
    descricao: 'Rum, hortelã e limão.',
    preco: 16.90,
    imagemUrl: 'assets/images/mojito.png',
    isAlcoolica: true,
  ),
  Bebida(
    id: '8',
    nome: 'Gin Tônica',
    descricao: 'Gin premium + água tônica.',
    preco: 18.50,
    imagemUrl: 'assets/images/gin.png',
    isAlcoolica: true,
  ),
  ];

  UnmodifiableListView<Bebida> get bebidas => UnmodifiableListView(_bebidas);

  Future<List<Bebida>> loadBebidas() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return bebidas;
  }

  Future<void> addBebida(Bebida bebida) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jaExiste = _bebidas.any(
      (item) => item.nome.toLowerCase() == bebida.nome.toLowerCase(),
    );
    if (jaExiste) {
      throw Exception('Ja existe uma bebida com esse nome.');
    }
    _bebidas.add(bebida);
  }
}
