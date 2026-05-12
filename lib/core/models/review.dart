class Review {
  final String id;
  final String orderId;
  final String reviewerId;
  final String farmerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final Map<String, dynamic>? reviewer;

  const Review({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.farmerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      reviewerId: json['reviewerId'] as String,
      farmerId: json['farmerId'] as String,
      rating: double.parse(json['rating'].toString()).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewer: json['reviewer'] != null ? Map<String, dynamic>.from(json['reviewer'] as Map) : null,
    );
  }

  String? get reviewerName => reviewer?['fullname'] as String?;
}
