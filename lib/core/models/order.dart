import '../enums/enums.dart';
import 'product.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double subtotal;
  final Product? product;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      quantity: double.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unitPrice'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      product: json['product'] != null
          ? Product.fromJson(Map<String, dynamic>.from(json['product'] as Map))
          : null,
    );
  }
}

class Order {
  final String id;
  final String buyerId;
  final String farmerId;
  final String? delivererId;
  final OrderStatus status;
  final DeliveryOption deliveryOption;
  final double totalPrice;
  final double? deliveryPrice;
  final double? distanceKm;
  final String? rejectionReason;
  final int? buyerCommuneId;
  final int? farmerCommuneId;
  final bool farmerConfirmedPickup;
  final bool buyerConfirmedPickup;
  final bool delivererConfirmedPickup;
  final bool buyerConfirmedDelivery;
  final bool delivererConfirmedDelivery;
  final List<OrderItem> items;
  final DateTime createdAt;

  // Populated relations (stored as plain maps for flexibility)
  final Map<String, dynamic>? buyer;
  final Map<String, dynamic>? farmer;
  final Map<String, dynamic>? deliverer;

  const Order({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    this.delivererId,
    required this.status,
    required this.deliveryOption,
    required this.totalPrice,
    this.deliveryPrice,
    this.distanceKm,
    this.rejectionReason,
    this.buyerCommuneId,
    this.farmerCommuneId,
    this.farmerConfirmedPickup = false,
    this.buyerConfirmedPickup = false,
    this.delivererConfirmedPickup = false,
    this.buyerConfirmedDelivery = false,
    this.delivererConfirmedDelivery = false,
    this.items = const [],
    required this.createdAt,
    this.buyer,
    this.farmer,
    this.deliverer,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      farmerId: json['farmerId'] as String,
      delivererId: json['delivererId'] as String?,
      status: OrderStatus.values.byName(json['status'] as String),
      deliveryOption:
          DeliveryOption.values.byName(json['deliveryOption'] as String),
      totalPrice: double.parse(json['totalPrice'].toString()),
      deliveryPrice: json['deliveryPrice'] != null ? double.parse(json['deliveryPrice'].toString()) : null,
      distanceKm: json['distanceKm'] != null ? double.parse(json['distanceKm'].toString()) : null,
      rejectionReason: json['rejectionReason'] as String?,
      buyerCommuneId: (json['buyerCommuneId'] as num?)?.toInt(),
      farmerCommuneId: (json['farmerCommuneId'] as num?)?.toInt(),
      farmerConfirmedPickup: json['farmerConfirmedPickup'] as bool? ?? false,
      buyerConfirmedPickup: json['buyerConfirmedPickup'] as bool? ?? false,
      delivererConfirmedPickup:
          json['delivererConfirmedPickup'] as bool? ?? false,
      buyerConfirmedDelivery: json['buyerConfirmedDelivery'] as bool? ?? false,
      delivererConfirmedDelivery:
          json['delivererConfirmedDelivery'] as bool? ?? false,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Use Map.from() so nested maps work on Flutter Web (Dio returns Map<String,Object?>)
      buyer: json['buyer'] != null
          ? Map<String, dynamic>.from(json['buyer'] as Map)
          : null,
      farmer: json['farmer'] != null
          ? Map<String, dynamic>.from(json['farmer'] as Map)
          : null,
      deliverer: json['deliverer'] != null
          ? Map<String, dynamic>.from(json['deliverer'] as Map)
          : null,
    );
  }

  String? get farmerName => farmer?['fullname'] as String?;
  String? get buyerName => buyer?['fullname'] as String?;
  String? get delivererName => deliverer?['fullname'] as String?;
  String? get farmerPhone => farmer?['phoneNumber'] as String?;
  String? get buyerPhone => buyer?['phoneNumber'] as String?;
  String? get delivererPhone => deliverer?['phoneNumber'] as String?;

  double get grandTotal => totalPrice + (deliveryPrice ?? 0);
}
