import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/core_providers.dart';

class MyProductsNotifier extends StateNotifier<AsyncValue<PaginatedProducts>> {
  final Ref _ref;

  MyProductsNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? search, int? categoryId}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref.read(apiServiceProvider).getMyProducts(
            search: search,
            categoryId: categoryId,
          );
      state = AsyncValue.data(result);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> deleteProduct(String id) async {
    await _ref.read(apiServiceProvider).deleteProduct(id);
    load();
  }

  Future<void> toggleAvailability(String id, bool isAvailable) async {
    await _ref
        .read(apiServiceProvider)
        .updateProduct(id, {'isAvailable': isAvailable});
    load();
  }
}

final myProductsProvider =
    StateNotifierProvider<MyProductsNotifier, AsyncValue<PaginatedProducts>>(
        (ref) => MyProductsNotifier(ref));

final farmerOrdersProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ref.watch(apiServiceProvider).getOrders();
});
