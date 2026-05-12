import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/order.dart';
import '../../../core/providers/core_providers.dart';

class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final Ref _ref;

  OrdersNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({OrderStatus? status}) async {
    state = const AsyncValue.loading();
    try {
      final orders = await _ref.read(apiServiceProvider).getOrders(status: status);
      state = AsyncValue.data(orders);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<Order> createOrder({
    required DeliveryOption deliveryOption,
    required int buyerCommuneId,
  }) async {
    final order = await _ref.read(apiServiceProvider).createOrder(
          deliveryOption: deliveryOption,
          buyerCommuneId: buyerCommuneId,
        );
    load();
    return order;
  }

  Future<void> confirmDelivery(String orderId) async {
    await _ref.read(apiServiceProvider).buyerConfirmDelivery(orderId);
    load();
  }

  Future<void> confirmPickup(String orderId) async {
    await _ref.read(apiServiceProvider).buyerConfirmPickup(orderId);
    load();
  }
}

final buyerOrdersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(ref);
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) async {
  return ref.watch(apiServiceProvider).getOrder(id);
});
