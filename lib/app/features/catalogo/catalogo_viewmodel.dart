import 'package:flutter/foundation.dart';

import '../../models/bebida.dart';
import '../../models/cart_model.dart';
import '../../repositories/bebidas_repository.dart';

class CatalogoViewModel extends ChangeNotifier {
  final BebidasRepository bebidasRepository;
  final CartModel cartModel;

  CatalogoViewModel({
    required this.bebidasRepository,
    required this.cartModel,
  });

  List<Bebida> bebidas = [];
  String feedback = '';
  int _nextId = 3;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bebidas = await bebidasRepository.loadBebidas();
    } catch (_) {
      errorMessage = 'Nao foi possivel carregar o catalogo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Bebida bebida) {
    cartModel.add(bebida);
    feedback = '${bebida.nome} adicionado a sacola';
    notifyListeners();
  }
  Future<bool> saveBebida({
    required String nome,
    required String descricao,
    required String precoText,
    required bool isAlcoolica,
  }) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    final preco = double.parse(precoText.replaceAll(',', '.'));
    try {
      await bebidasRepository.addBebida(
        Bebida(
          id: (_nextId++).toString(),
          nome: nome,
          descricao: descricao,
          preco: preco,
          imagemUrl: isAlcoolica
              ? 'assets/images/ipa.png'
              : 'assets/images/suco.png',
          isAlcoolica: isAlcoolica,
        ),
      );
      await load();
      feedback = '$nome cadastrada no catalogo';
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearFeedback() {
    if (feedback.isEmpty) return;
    feedback = '';
    notifyListeners();
  }
}
