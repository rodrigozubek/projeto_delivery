import 'package:flutter/material.dart';
import '../models/bebida.dart';

class BebidaController extends ChangeNotifier {

  final List<Bebida> _produtos = [
    Bebida(
      id: '1',
      nome: 'Cerveja Artesanal IPA',
      descricao: '500ml - Notas cítricas e amargor moderado.',
      preco: 18.90,
      imagemUrl: 'assets/images/ipa.png',
      isAlcoolica: true,
    ),
    Bebida(
      id: '2',
      nome: 'Suco de Laranja Natural',
      descricao: '400ml - Sem adição de açúcar.',
      preco: 9.50,
      imagemUrl: 'assets/images/suco.png',
      isAlcoolica: false,
    ),
  ];

  List<Bebida> get produtos => [..._produtos];

  List<Bebida> get apenasAlcoolicas => 
      _produtos.where((b) => b.isAlcoolica).toList();
}