import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/catalogo/catalogo_viewmodel.dart';
import 'models/cart_model.dart';
import 'repositories/bebidas_repository.dart';
import '../routing/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => BebidasRepository()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(
          create: (context) => CatalogoViewModel(
            bebidasRepository: context.read<BebidasRepository>(),
            cartModel: context.read<CartModel>(),
          )..load(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Delivery de Bebidas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
