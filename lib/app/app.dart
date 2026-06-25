import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'features/catalogo/catalogo_viewmodel.dart';
import 'models/auth_model.dart';
import 'models/cart_model.dart';
import 'repositories/bebidas_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/users_repository.dart';
import 'repositories/pedidos_repository.dart';
import '../routing/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AppDatabase()),
        Provider(
          create: (context) =>
              BebidasRepository(appDatabase: context.read<AppDatabase>()),
        ),
        Provider(
          create: (context) =>
              CartRepository(appDatabase: context.read<AppDatabase>()),
        ),
        Provider(
          create: (context) =>
              UsersRepository(appDatabase: context.read<AppDatabase>()),
        ),
        Provider(
          create: (context) =>
              PedidosRepository(appDatabase: context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              AuthModel(usersRepository: context.read<UsersRepository>())
                ..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CartModel(cartRepository: context.read<CartRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogoViewModel(
            bebidasRepository: context.read<BebidasRepository>(),
            cartModel: context.read<CartModel>(),
          )..load(),
        ),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(context.read<AuthModel>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Delivery de Bebidas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE85D04),
          primary: const Color(0xFFE85D04),
          secondary: const Color(0xFF2E7D32),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6F2),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F6F2),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE85D04),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFBFAF8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
