import 'dart:convert';

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<CustomerAddress> addresses;
  final bool isActive;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.addresses,
    this.isActive = true,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.lastOrderDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Parse addresses
    List<CustomerAddress> addressList = [];
    if (json['addresses'] != null) {
      if (json['addresses'] is String) {
        try {
          final decoded = jsonDecode(json['addresses']);
          if (decoded is List) {
            addressList = decoded
                .map((addr) => CustomerAddress.fromJson(addr))
                .toList();
          }
        } catch (e) {
          addressList = [];
        }
      } else if (json['addresses'] is List) {
        addressList = (json['addresses'] as List)
            .map((addr) => CustomerAddress.fromJson(addr))
            .toList();
      }
    }

    return Customer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      addresses: addressList,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? '0') ?? 0,
      totalSpent: double.tryParse(json['total_spent']?.toString() ?? '0') ?? 0.0,
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'is_active': isActive ? 1 : 0,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'last_order_date': lastOrderDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // For form data submission
  Map<String, dynamic> toFormData() {
    return {
      'name': name,
      'phone': phone,
      'is_active': isActive ? '1' : '0',
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    List<CustomerAddress>? addresses,
    bool? isActive,
    int? totalOrders,
    double? totalSpent,
    DateTime? lastOrderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      addresses: addresses ?? this.addresses,
      isActive: isActive ?? this.isActive,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => name.isNotEmpty ? name : email;
  String get initials {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }
}

class CustomerAddress {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;

  CustomerAddress({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id']?.toString() ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      country: json['country'] ?? 'Saudi Arabia',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get fullAddress {
    final components = [street, city, state, zipCode, country];
    return components.where((component) => component.isNotEmpty).join(', ');
  }

  CustomerAddress copyWith({
    String? id,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}