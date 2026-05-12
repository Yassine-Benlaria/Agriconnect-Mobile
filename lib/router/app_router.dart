import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/models/auth_state.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/register_buyer_screen.dart';
import '../features/auth/screens/register_deliverer_screen.dart';
import '../features/auth/screens/register_farmer_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/buyer/screens/buyer_shell.dart';
import '../features/buyer/screens/cart_screen.dart';
import '../features/buyer/screens/home_screen.dart';
import '../features/buyer/screens/order_detail_screen.dart';
import '../features/buyer/screens/orders_list_screen.dart';
import '../features/buyer/screens/product_detail_screen.dart';
import '../features/deliverer/screens/available_tasks_screen.dart';
import '../features/deliverer/screens/current_task_screen.dart';
import '../features/deliverer/screens/deliverer_shell.dart';
import '../features/deliverer/screens/task_detail_screen.dart';
import '../features/farmer/screens/dashboard_screen.dart';
import '../features/farmer/screens/farmer_order_detail_screen.dart';
import '../features/farmer/screens/farmer_shell.dart';
import '../features/farmer/screens/my_products_screen.dart';
import '../features/farmer/screens/product_form_screen.dart';
import '../features/shared/screens/profile_screen.dart';
import '../features/shared/screens/review_screen.dart';
import '../core/enums/enums.dart';

// Route names
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const registerBuyer = '/register/buyer';
  static const registerFarmer = '/register/farmer';
  static const registerDeliverer = '/register/deliverer';

  // Buyer
  static const buyerHome = '/buyer/home';
  static const productDetail = '/buyer/product/:id';
  static const buyerCart = '/buyer/cart';
  static const buyerOrders = '/buyer/orders';
  static const buyerOrderDetail = '/buyer/orders/:id';
  static const reviewOrder = '/buyer/orders/:id/review';

  // Farmer
  static const farmerDashboard = '/farmer/dashboard';
  static const myProducts = '/farmer/products';
  static const addProduct = '/farmer/products/new';
  static const editProduct = '/farmer/products/:id/edit';
  static const farmerOrders = '/farmer/orders';
  static const farmerOrderDetail = '/farmer/orders/:id';

  // Deliverer
  static const delivererTasks = '/deliverer/tasks';
  static const taskDetail = '/deliverer/tasks/:id';
  static const currentTask = '/deliverer/current';

  // Shared
  static const profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loc = state.uri.path;

      // Don't redirect while loading
      if (authState.status == AuthStatus.unknown) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.onboarding ||
          loc.startsWith('/register');

      if (authState.status == AuthStatus.unauthenticated) {
        if (!isAuthRoute && loc != AppRoutes.splash) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // Authenticated user hitting auth routes → redirect to their home
      if (isAuthRoute || loc == AppRoutes.splash) {
        return _homeForRole(authState.role);
      }

      // Authenticated user trying to access wrong role's routes
      final role = authState.role;
      if (role == UserRole.BUYER && loc.startsWith('/farmer')) {
        return AppRoutes.buyerHome;
      }
      if (role == UserRole.BUYER && loc.startsWith('/deliverer')) {
        return AppRoutes.buyerHome;
      }
      if (role == UserRole.FARMER && loc.startsWith('/buyer')) {
        return AppRoutes.farmerDashboard;
      }
      if (role == UserRole.FARMER && loc.startsWith('/deliverer')) {
        return AppRoutes.farmerDashboard;
      }
      if (role == UserRole.DELIVERER && loc.startsWith('/buyer')) {
        return AppRoutes.delivererTasks;
      }
      if (role == UserRole.DELIVERER && loc.startsWith('/farmer')) {
        return AppRoutes.delivererTasks;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.registerBuyer,
        builder: (_, __) => const RegisterBuyerScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerFarmer,
        builder: (_, __) => const RegisterFarmerScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerDeliverer,
        builder: (_, __) => const RegisterDelivererScreen(),
      ),

      // ── BUYER SHELL ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => BuyerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.buyerHome,
            builder: (_, __) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'product/:id',
                builder: (context, state) =>
                    ProductDetailScreen(productId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.buyerCart,
            builder: (_, __) => const CartScreen(),
          ),
          GoRoute(
            path: AppRoutes.buyerOrders,
            builder: (_, __) => const OrdersListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    OrderDetailScreen(orderId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'review',
                    builder: (context, state) =>
                        ReviewScreen(orderId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── FARMER SHELL ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => FarmerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.farmerDashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.myProducts,
            builder: (_, __) => const MyProductsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const ProductFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) => ProductFormScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.farmerOrders,
            builder: (_, __) =>
                const FarmerOrderDetailScreen(orderId: '', listMode: true),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => FarmerOrderDetailScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/farmer/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── DELIVERER SHELL ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => DelivererShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.delivererTasks,
            builder: (_, __) => const AvailableTasksScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    TaskDetailScreen(orderId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.currentTask,
            builder: (_, __) => const CurrentTaskScreen(),
          ),
          GoRoute(
            path: '/deliverer/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

String? _homeForRole(UserRole? role) {
  switch (role) {
    case UserRole.BUYER:
      return AppRoutes.buyerHome;
    case UserRole.FARMER:
      return AppRoutes.farmerDashboard;
    case UserRole.DELIVERER:
      return AppRoutes.delivererTasks;
    default:
      return AppRoutes.onboarding;
  }
}

/// Converts a StateNotifier stream to a Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
