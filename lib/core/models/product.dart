import 'user.dart';

class Category {
  final int id;
  final String name;
  final String? icon;

  const Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }
}

class ProductImage {
  final String id;
  final String url;
  final int displayOrder;

  const ProductImage({
    required this.id,
    required this.url,
    required this.displayOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as String,
      url: json['url'] as String,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class Product {
  final String id;
  final String farmerId;
  final String title;
  final String? description;
  final double price;
  final String priceUnit;
  final int categoryId;
  final Category? category;
  final double quantity;
  final int? wilayaId;
  final int? communeId;
  final bool isAvailable;
  final double rating;
  final int ratingCount;
  final List<ProductImage> images;
  final DateTime createdAt;

  // Farmer public info (from browse endpoint)
  final String? farmerName;
  final double? farmerRating;
  final String? farmerAvatarUrl;

  const Product({
    required this.id,
    required this.farmerId,
    required this.title,
    this.description,
    required this.price,
    required this.priceUnit,
    required this.categoryId,
    this.category,
    required this.quantity,
    this.wilayaId,
    this.communeId,
    this.isAvailable = true,
    this.rating = 0,
    this.ratingCount = 0,
    this.images = const [],
    required this.createdAt,
    this.farmerName,
    this.farmerRating,
    this.farmerAvatarUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // On Flutter Web, nested maps from Dio come as Map<String, Object?> — use .from()
    final farmer = json['farmer'] != null
        ? Map<String, dynamic>.from(json['farmer'] as Map)
        : null;
    return Product(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      priceUnit: json['priceUnit'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      category: json['category'] != null
          ? Category.fromJson(
              Map<String, dynamic>.from(json['category'] as Map))
          : null,
      quantity: double.parse(json['quantity'].toString()),
      wilayaId: (json['wilayaId'] as num?)?.toInt(),
      communeId: (json['communeId'] as num?)?.toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) =>
                  ProductImage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      farmerName: farmer?['fullname'] as String?,
      farmerRating: farmer?['rating'] != null ? double.parse(farmer!['rating'].toString()) : null,
      farmerAvatarUrl: farmer?['avatarUrl'] as String?,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(0)} DZD/$priceUnit';

  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final sorted = List<ProductImage>.from(images)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return sorted.first.url;
  }
}

class PaginatedProducts {
  final List<Product> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedProducts({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedProducts(
      data: (json['data'] as List<dynamic>)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: (meta['total'] as num?)?.toInt() ?? 0,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
