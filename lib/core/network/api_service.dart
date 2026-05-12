import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../enums/enums.dart';
import '../models/cart.dart';
import '../models/commune.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/wilaya.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // ─── AUTH ─────────────────────────────────────────────────────────────────

  Future<Map<String, String>> login(String email, String password) async {
    final res = await _dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  Future<Map<String, String>> registerBuyer(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.registerBuyer, data: data);
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  Future<Map<String, String>> registerFarmer(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.registerFarmer, data: data);
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  Future<Map<String, String>> registerDeliverer(
      Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.registerDeliverer, data: data);
    return {
      'accessToken': res.data['accessToken'] as String,
      'refreshToken': res.data['refreshToken'] as String,
    };
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {}
  }

  // ─── USERS ────────────────────────────────────────────────────────────────

  Future<User> getMe() async {
    final res = await _dio.get(ApiConstants.me);
    return User.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<User> updateMe(Map<String, dynamic> data) async {
    final res = await _dio.patch(ApiConstants.me, data: data);
    return User.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<User> getFarmerProfile(String farmerId) async {
    final res = await _dio.get('${ApiConstants.farmers}/$farmerId');
    return User.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ─── GEO ──────────────────────────────────────────────────────────────────

  Future<List<Wilaya>> getWilayas() async {
    final res = await _dio.get(ApiConstants.wilayas);
    return (res.data as List<dynamic>)
        .map((e) => Wilaya.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Commune>> getCommunes(int wilayaId) async {
    final res =
        await _dio.get('${ApiConstants.wilayas}/$wilayaId/communes');
    return (res.data as List<dynamic>)
        .map((e) => Commune.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ─── CATEGORIES ───────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final res = await _dio.get(ApiConstants.categories);
    return (res.data as List<dynamic>)
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ─── PRODUCTS ─────────────────────────────────────────────────────────────

  Future<PaginatedProducts> getProducts({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? search,
    ProductSortBy? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      ApiConstants.products,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sortBy': sortBy.name,
        'page': page,
        'limit': limit,
      },
    );
    return PaginatedProducts.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Product> getProduct(String id) async {
    final res = await _dio.get('${ApiConstants.products}/$id');
    return Product.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<PaginatedProducts> getMyProducts({
    int? categoryId,
    String? search,
    ProductSortBy? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      ApiConstants.myProducts,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sortBy': sortBy.name,
        'page': page,
        'limit': limit,
      },
    );
    return PaginatedProducts.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.products, data: data);
    return Product.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await _dio.patch('${ApiConstants.products}/$id', data: data);
    return Product.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('${ApiConstants.products}/$id');
  }

  Future<List<ProductImage>> uploadProductImages(
      String productId, List<String> filePaths) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(path)),
      );
    }
    final res = await _dio.post(
      '${ApiConstants.products}/$productId/images',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data as List<dynamic>)
        .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteProductImage(String productId, String imageId) async {
    await _dio
        .delete('${ApiConstants.products}/$productId/images/$imageId');
  }

  // ─── CART ─────────────────────────────────────────────────────────────────

  Future<Cart> getCart() async {
    final res = await _dio.get(ApiConstants.cart);
    return Cart.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Cart> addToCart(String productId, double quantity) async {
    final res = await _dio.post(ApiConstants.cartItems, data: {
      'productId': productId,
      'quantity': quantity,
    });
    return Cart.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Cart> updateCartItem(String productId, double quantity) async {
    final res = await _dio.patch(
      '${ApiConstants.cartItems}/$productId',
      data: {'quantity': quantity},
    );
    return Cart.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Cart> removeCartItem(String productId) async {
    final res =
        await _dio.delete('${ApiConstants.cartItems}/$productId');
    return Cart.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Cart> clearCart() async {
    final res = await _dio.delete(ApiConstants.cart);
    return Cart.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ─── ORDERS ───────────────────────────────────────────────────────────────

  Future<Order> createOrder({
    required DeliveryOption deliveryOption,
    required int buyerCommuneId,
  }) async {
    final res = await _dio.post(ApiConstants.orders, data: {
      'deliveryOption': deliveryOption.name,
      'buyerCommuneId': buyerCommuneId,
    });
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<Order>> getOrders({OrderStatus? status}) async {
    final res = await _dio.get(
      ApiConstants.orders,
      queryParameters: {
        if (status != null) 'status': status.name,
      },
    );
    return (res.data as List<dynamic>)
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Order> getOrder(String id) async {
    final res = await _dio.get('${ApiConstants.orders}/$id');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> acceptOrder(String id) async {
    final res = await _dio.patch('${ApiConstants.orders}/$id/accept');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> rejectOrder(String id, String reason) async {
    final res = await _dio.patch(
      '${ApiConstants.orders}/$id/reject',
      data: {'rejectionReason': reason},
    );
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> farmerConfirmPickup(String id) async {
    final res =
        await _dio.patch('${ApiConstants.orders}/$id/confirm-pickup');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> buyerConfirmPickup(String id) async {
    final res = await _dio
        .patch('${ApiConstants.orders}/$id/buyer-confirm-pickup');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> buyerConfirmDelivery(String id) async {
    final res =
        await _dio.patch('${ApiConstants.orders}/$id/confirm-delivery');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ─── DELIVERIES ───────────────────────────────────────────────────────────

  Future<List<Order>> getAvailableDeliveries() async {
    final res = await _dio.get(ApiConstants.deliveriesAvailable);
    return (res.data as List<dynamic>)
        .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Order> getDeliveryDetail(String orderId) async {
    final res = await _dio.get('/deliveries/$orderId');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> assignDelivery(String orderId) async {
    final res = await _dio.post('/deliveries/$orderId/assign');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order?> getCurrentDelivery() async {
    try {
      final res = await _dio.get(ApiConstants.deliveriesCurrent);
      if (res.data == null) return null;
      return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<Order> delivererConfirmPickup(String orderId) async {
    final res =
        await _dio.patch('/deliveries/$orderId/confirm-pickup');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Order> delivererConfirmDelivery(String orderId) async {
    final res =
        await _dio.patch('/deliveries/$orderId/confirm-delivery');
    return Order.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // ─── REVIEWS ──────────────────────────────────────────────────────────────

  Future<Review> submitReview({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final res = await _dio.post(ApiConstants.reviews, data: {
      'orderId': orderId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return Review.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<Review>> getFarmerReviews(String farmerId) async {
    final res =
        await _dio.get('${ApiConstants.reviews}/farmer/$farmerId');
    return (res.data as List<dynamic>)
        .map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Review?> getOrderReview(String orderId) async {
    try {
      final res =
          await _dio.get('${ApiConstants.reviews}/order/$orderId');
      if (res.data == null) return null;
      return Review.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (_) {
      return null;
    }
  }
}
