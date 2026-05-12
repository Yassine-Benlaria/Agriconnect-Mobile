import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order.dart';
import '../../../core/providers/core_providers.dart';

final availableDeliveriesProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  return ref.watch(apiServiceProvider).getAvailableDeliveries();
});

final currentDeliveryProvider =
    FutureProvider.autoDispose<Order?>((ref) async {
  return ref.watch(apiServiceProvider).getCurrentDelivery();
});

class DeliveryActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  DeliveryActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<Order> assign(String orderId) async {
    state = const AsyncValue.loading();
    try {
      final order = await _ref.read(apiServiceProvider).assignDelivery(orderId);
      state = const AsyncValue.data(null);
      return order;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> confirmPickup(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiServiceProvider).delivererConfirmPickup(orderId);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  Future<void> confirmDelivery(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiServiceProvider).delivererConfirmDelivery(orderId);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }
}

final deliveryActionsProvider =
    StateNotifierProvider<DeliveryActionsNotifier, AsyncValue<void>>(
        (ref) => DeliveryActionsNotifier(ref));
