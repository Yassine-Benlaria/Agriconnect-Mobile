import 'product.dart';

class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final double quantity;
  final Product? product;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cartId'] as String,
      productId: json['productId'] as String,
      quantity: double.parse(json['quantity'].toString()),
      product: json['product'] != null
          ? Product.fromJson(Map<String, dynamic>.from(json['product'] as Map))
          : null,
    );
  }

  double get subtotal => (product?.price ?? 0) * quantity;
}

class Cart {
  final String id;
  final String buyerId;
  final List<CartItem> items;

  const Cart({
    required this.id,
    required this.buyerId,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => items.isEmpty;
}
