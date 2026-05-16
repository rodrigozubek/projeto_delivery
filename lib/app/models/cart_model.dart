import 'package:flutter/foundation.dart';

import '../repositories/cart_repository.dart';
import 'bebida.dart';
import 'cart_entry.dart';

export 'cart_entry.dart';

class CartModel extends ChangeNotifier {
  final CartRepository cartRepository;
  final List<CartEntry> _items = [];
  bool isLoading = false;

  CartModel({required this.cartRepository});

  List<CartEntry> get items => List.unmodifiable(_items);

  double get total =>
      _items.fold(0.0, (s, e) => s + e.bebida.preco * e.quantity);

  int get itemCount => _items.length;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final savedItems = await cartRepository.loadItems();
    _items
      ..clear()
      ..addAll(savedItems);

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(Bebida bebida, {int quantity = 1}) async {
    final idx = _items.indexWhere((e) => e.bebida.id == bebida.id);
    if (idx >= 0) {
      _items[idx].quantity = _limitQuantity(_items[idx].quantity + quantity);
      await cartRepository.saveItem(bebida.id, _items[idx].quantity);
    } else {
      final safeQuantity = _limitQuantity(quantity);
      _items.add(CartEntry(bebida: bebida, quantity: safeQuantity));
      await cartRepository.saveItem(bebida.id, safeQuantity);
    }
    notifyListeners();
  }

  Future<void> remove(String bebidaId) async {
    _items.removeWhere((e) => e.bebida.id == bebidaId);
    await cartRepository.removeItem(bebidaId);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await cartRepository.clear();
    notifyListeners();
  }

  Future<void> changeQuantity(String bebidaId, int delta) async {
    final idx = _items.indexWhere((e) => e.bebida.id == bebidaId);
    if (idx < 0) return;
    final entry = _items[idx];
    entry.quantity = _limitQuantity(entry.quantity + delta);
    await cartRepository.saveItem(bebidaId, entry.quantity);
    notifyListeners();
  }

  Future<void> setQuantity(String bebidaId, int quantity) async {
    final idx = _items.indexWhere((e) => e.bebida.id == bebidaId);
    if (idx < 0) return;
    _items[idx].quantity = _limitQuantity(quantity);
    await cartRepository.saveItem(bebidaId, _items[idx].quantity);
    notifyListeners();
  }

  int _limitQuantity(int quantity) {
    return quantity.clamp(1, 99).toInt();
  }
}
