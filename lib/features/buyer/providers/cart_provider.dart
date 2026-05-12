import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cart.dart';
import '../../../core/providers/core_providers.dart';

class CartNotifier extends StateNotifier<AsyncValue<Cart?>> {
  final Ref _ref;

  CartNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _ref.read(apiServiceProvider).getCart();
      state = AsyncValue.data(cart);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addItem(String productId, double quantity) async {
    try {
      final cart =
          await _ref.read(apiServiceProvider).addToCart(productId, quantity);
      state = AsyncValue.data(cart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(String productId, double quantity) async {
    try {
      final cart = await _ref
          .read(apiServiceProvider)
          .updateCartItem(productId, quantity);
      state = AsyncValue.data(cart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      final cart =
          await _ref.read(apiServiceProvider).removeCartItem(productId);
      state = AsyncValue.data(cart);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final cart = await _ref.read(apiServiceProvider).clearCart();
      state = AsyncValue.data(cart);
    } catch (e) {
      rethrow;
    }
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Cart?>>((ref) {
  return CartNotifier(ref);
});

/// Cart item count badge
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).maybeWhen(
        data: (cart) => cart?.items.length ?? 0,
        orElse: () => 0,
      );
});
