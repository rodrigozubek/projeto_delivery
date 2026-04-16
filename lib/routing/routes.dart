import 'package:go_router/go_router.dart';

import '../app/features/sacola/cart_view.dart';
import '../app/features/catalogo/cadastrar_bebida_screen.dart';
import '../app/features/catalogo/catalogo_screen.dart';
import '../app/features/catalogo/pagamento_screen.dart';

class AppRoutes {
  static const catalogo = '/';
  static const cadastrarBebida = '/cadastrar-bebida';
  static const sacola = '/sacola';
  static const pagamento = '/sacola/pagamento';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.catalogo,
  routes: [
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
  ],
);
