import 'bebida.dart';

class CartEntry {
  final Bebida bebida;
  int quantity;

  CartEntry({required this.bebida, this.quantity = 1});
}
