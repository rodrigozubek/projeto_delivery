import 'package:go_router/go_router.dart';

import '../app/features/auth/cadastro_screen.dart';
import '../app/features/auth/login_screen.dart';
import '../app/features/sacola/cart_view.dart';
import '../app/features/catalogo/cadastrar_bebida_screen.dart';
import '../app/features/catalogo/catalogo_screen.dart';
import '../app/features/catalogo/pagamento_screen.dart';
import '../app/features/catalogo/pedidos_screen.dart';
import '../app/models/auth_model.dart';

class AppRoutes {
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const catalogo = '/';
  static const cadastrarBebida = '/cadastrar-bebida';
  static const sacola = '/sacola';
  static const pagamento = '/sacola/pagamento';
  static const pedidos = '/pedidos';
}

GoRouter createAppRouter(AuthModel authModel) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authModel,
    redirect: (context, state) {
      if (authModel.isInitializing) {
        return null;
      }

      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.cadastro;

      if (!authModel.isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (isAuthRoute) {
        return AppRoutes.catalogo;
      }

      if (state.matchedLocation == AppRoutes.cadastrarBebida &&
          !authModel.isAdmin) {
        return AppRoutes.catalogo;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalogo,
        builder: (context, state) => const CatalogoScreen(),
      ),
      GoRoute(
        path: AppRoutes.cadastrarBebida,
        builder: (context, state) => const CadastrarBebidaScreen(),
      ),
      GoRoute(
        path: AppRoutes.sacola,
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: AppRoutes.pagamento,
        builder: (context, state) => const PagamentoScreen(),
      ),
      GoRoute(
        path: AppRoutes.pedidos,
        builder: (context, state) => const PedidosScreen(),
      ),
    ],
  );
}
