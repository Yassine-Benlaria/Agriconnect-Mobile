import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/core_providers.dart';

// Filter state
class ProductFilter {
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String search;
  final ProductSortBy sortBy;

  const ProductFilter({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.search = '',
    this.sortBy = ProductSortBy.date_desc,
  });

  ProductFilter copyWith({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? search,
    ProductSortBy? sortBy,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

final productFilterProvider =
    StateProvider<ProductFilter>((ref) => const ProductFilter());

final productsProvider =
    FutureProvider.autoDispose<PaginatedProducts>((ref) async {
  final filter = ref.watch(productFilterProvider);
  final api = ref.watch(apiServiceProvider);
  return api.getProducts(
    categoryId: filter.categoryId,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    search: filter.search,
    sortBy: filter.sortBy,
  );
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.getProduct(id);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getCategories();
});
