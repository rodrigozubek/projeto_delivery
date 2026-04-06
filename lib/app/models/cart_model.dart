import 'package:flutter/foundation.dart';
import 'bebida.dart'; // importe sua classe Bebida

class CartEntry {
  final Bebida bebida;
  int quantity;
  CartEntry({required this.bebida, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => List.unmodifiable(_items);

  double get total => _items.fold(0.0, (s, e) => s + e.bebida.preco * e.quantity);

  int get itemCount => _items.length;

  void add(Bebida bebida, {int quantity = 1}) {
    final idx = _items.indexWhere((e) => e.bebida.id == bebida.id);
    if (idx >= 0) {
      _items[idx].quantity = (_items[idx].quantity + quantity).clamp(1, 99);
    } else {
      _items.add(CartEntry(bebida: bebida, quantity: quantity.clamp(1, 99)));
    }
    notifyListeners();
  }

  void remove(String bebidaId) {
    _items.removeWhere((e) => e.bebida.id == bebidaId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void changeQuantity(String bebidaId, int delta) {
    final idx = _items.indexWhere((e) => e.bebida.id == bebidaId);
    if (idx < 0) return;
    final entry = _items[idx];
    entry.quantity = (entry.quantity + delta).clamp(1, 99);
    notifyListeners();
  }

  void setQuantity(String bebidaId, int quantity) {
    final idx = _items.indexWhere((e) => e.bebida.id == bebidaId);
    if (idx < 0) return;
    _items[idx].quantity = quantity.clamp(1, 99);
    notifyListeners();
  }
}