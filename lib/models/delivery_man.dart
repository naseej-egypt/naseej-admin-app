import 'package:flutter/material.dart';

class DeliveryMan {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String vehicleType;
  final String vehicleNumber;
  final String status;
  final bool isActive;
  final double rating;
  final int totalDeliveries;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? password; // For creating new delivery man

  DeliveryMan({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.status,
    this.isActive = true,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    required this.createdAt,
    this.updatedAt,
    this.currentLatitude,
    this.currentLongitude,
    this.password,
  });

  factory DeliveryMan.fromJson(Map<String, dynamic> json) {
    return DeliveryMan(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      vehicleType: json['vehicle_type'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      status: json['status'] ?? 'available',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalDeliveries: int.tryParse(json['total_deliveries']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      currentLatitude: json['current_latitude'] != null
          ? double.tryParse(json['current_latitude'].toString())
          : null,
      currentLongitude: json['current_longitude'] != null
          ? double.tryParse(json['current_longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'status': status,
      'is_active': isActive ? 1 : 0,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'current_latitude': currentLatitude?.toString(),
      'current_longitude': currentLongitude?.toString(),
      if (password != null) 'password': password,
    };
  }

  Map<String, dynamic> toFormData() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'is_active': isActive ? '1' : '0',
      if (password != null) 'password': password!,
    };
  }

  Map<String, dynamic> toUpdateFormData() {
    return {
      'delivery_man_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'is_active': isActive ? '1' : '0',
    };
  }

  DeliveryMan copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? vehicleType,
    String? vehicleNumber,
    String? status,
    bool? isActive,
    double? rating,
    int? totalDeliveries,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentLatitude,
    double? currentLongitude,
    String? password,
  }) {
    return DeliveryMan(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      password: password ?? this.password,
    );
  }

  bool get isAvailable => status == 'available' && isActive;
  bool get isBusy => status == 'busy';
  bool get isOffline => status == 'offline';

  String get statusDisplay {
    switch (status) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'offline':
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}