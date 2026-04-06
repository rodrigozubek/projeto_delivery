import 'package:flutter/material.dart';
import 'app/models/cart_model.dart';
import 'app/app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const App(),
    ),
  );
}