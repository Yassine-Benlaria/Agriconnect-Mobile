import '../enums/enums.dart';
import 'commune.dart';
import 'wilaya.dart';

class User {
  final String id;
  final String fullname;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? avatarUrl;
  final UserRole role;
  final double rating;
  final int ratingCount;
  final int? wilayaId;
  final Wilaya? wilaya;
  final FarmerProfile? farmerProfile;
  final DelivererProfile? delivererProfile;

  const User({
    required this.id,
    required this.fullname,
    required this.email,
    this.phoneNumber,
    this.address,
    this.avatarUrl,
    required this.role,
    this.rating = 0,
    this.ratingCount = 0,
    this.wilayaId,
    this.wilaya,
    this.farmerProfile,
    this.delivererProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.values.byName(json['role'] as String),
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      wilayaId: (json['wilayaId'] as num?)?.toInt(),
      wilaya: json['wilaya'] != null
          ? Wilaya.fromJson(Map<String, dynamic>.from(json['wilaya'] as Map))
          : null,
      farmerProfile: json['farmerProfile'] != null
          ? FarmerProfile.fromJson(
              Map<String, dynamic>.from(json['farmerProfile'] as Map))
          : null,
      delivererProfile: json['delivererProfile'] != null
          ? DelivererProfile.fromJson(
              Map<String, dynamic>.from(json['delivererProfile'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'avatarUrl': avatarUrl,
        'role': role.name,
        'rating': rating,
        'ratingCount': ratingCount,
        'wilayaId': wilayaId,
      };
}

class FarmerProfile {
  final String id;
  final String userId;
  final int? communeId;
  final Commune? commune;
  final String? exactAddress;
  final double? landArea;
  final ActivityType activityType;

  const FarmerProfile({
    required this.id,
    required this.userId,
    this.communeId,
    this.commune,
    this.exactAddress,
    this.landArea,
    required this.activityType,
  });

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      communeId: (json['communeId'] as num?)?.toInt(),
      commune: json['commune'] != null
          ? Commune.fromJson(Map<String, dynamic>.from(json['commune'] as Map))
          : null,
      exactAddress: json['exactAddress'] as String?,
      landArea: json['landArea'] != null ? double.parse(json['landArea'].toString()) : null,
      activityType: ActivityType.values.byName(json['activityType'] as String),
    );
  }
}

class DelivererProfile {
  final String id;
  final String userId;
  final VehicleType vehicleType;
  final String? matricule;
  final bool isAvailable;
  final String? currentOrderId;

  const DelivererProfile({
    required this.id,
    required this.userId,
    required this.vehicleType,
    this.matricule,
    this.isAvailable = true,
    this.currentOrderId,
  });

  factory DelivererProfile.fromJson(Map<String, dynamic> json) {
    return DelivererProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleType: VehicleType.values.byName(json['vehicleType'] as String),
      matricule: json['matricule'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      currentOrderId: json['currentOrderId'] as String?,
    );
  }
}
