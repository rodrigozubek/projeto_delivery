import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/bebida_controller.dart';
import 'views/catalogo_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BebidaController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery de Bebidas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const CatalogoView(),
    );
  }
}