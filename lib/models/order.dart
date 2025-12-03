import 'dart:convert';
import 'package:flutter/material.dart';

class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? deliveryManId;
  final String? deliveryManName;
  final Address deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final int itemCount;
  final String? storeName;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.deliveryManId,
    this.deliveryManName,
    required this.deliveryAddress,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    required this.itemCount,
    this.storeName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    print('=== Order.fromJson Debug ===');
    print('Full JSON keys: ${json.keys.toList()}');
    print('Items data: ${json['items']}');
    print('Items type: ${json['items']?.runtimeType}');
    print('Item count from API: ${json['item_count']}');

    // Parse order items - IMPROVED PARSING
    List<OrderItem> orderItems = [];

    if (json['items'] != null) {
      if (json['items'] is List) {
        final itemsList = json['items'] as List;
        print('Found ${itemsList.length} items in List format');

        for (var i = 0; i < itemsList.length; i++) {
          print('Item $i data: ${itemsList[i]}');
          if (itemsList[i] != null) {
            try {
              final item = OrderItem.fromJson(itemsList[i]);
              orderItems.add(item);
              print('Successfully parsed item $i: ${item.productName}');
            } catch (e) {
              print('Error parsing item $i: $e');
            }
          }
        }
      } else if (json['items'] is String) {
        // Handle case where items is a JSON string
        try {
          final itemsList = jsonDecode(json['items']) as List;
          print('Found ${itemsList.length} items in String format');

          for (var i = 0; i < itemsList.length; i++) {
            if (itemsList[i] != null) {
              try {
                final item = OrderItem.fromJson(itemsList[i]);
                orderItems.add(item);
                print('Successfully parsed item $i from string: ${item.productName}');
              } catch (e) {
                print('Error parsing item $i from string: $e');
              }
            }
          }
        } catch (e) {
          print('Error decoding items string: $e');
        }
      }
    } else {
      print('Items is null');
    }

    print('Successfully parsed ${orderItems.length} order items');

    // Parse delivery address
    Address deliveryAddr;
    if (json['delivery_address'] != null) {
      if (json['delivery_address'] is String) {
        try {
          final decoded = jsonDecode(json['delivery_address']);
          deliveryAddr = Address.fromJson(decoded);
        } catch (e) {
          print('Error parsing delivery address string: $e');
          deliveryAddr = Address(
            street: json['delivery_address'] ?? '',
            city: '',
            state: '',
            zipCode: '',
            country: '',
          );
        }
      } else {
        deliveryAddr = Address.fromJson(Map<String, dynamic>.from(json['delivery_address']));
      }
    } else {
      deliveryAddr = Address(
        street: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
      );
    }

    // Calculate item count - use actual items count if available, otherwise use item_count field
    final actualItemCount = orderItems.isNotEmpty ? orderItems.length : (json['item_count'] != null ? int.tryParse(json['item_count'].toString()) ?? 0 : 0);

    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? 'Unknown Customer',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      items: orderItems,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      deliveryManId: json['delivery_man_id']?.toString(),
      deliveryManName: json['delivery_man_name'],
      deliveryAddress: deliveryAddr,
      notes: json['notes'],
      itemCount: actualItemCount,
      storeName: json['store_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString().replaceAll(' ', 'T'))
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString().replaceAll(' ', 'T'))
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'].toString().replaceAll(' ', 'T'))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'delivery_man_id': deliveryManId,
      'delivery_man_name': deliveryManName,
      'delivery_address': deliveryAddress.toJson(),
      'notes': notes,
      'item_count': itemCount,
      'store_name': storeName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  Color get paymentStatusColor {
    switch (paymentStatus) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  bool get canAssignDelivery =>
      status != 'cancelled' && status != 'delivered';

  bool get canCancel =>
      status != 'cancelled' && status != 'delivered';

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? deliveryManId,
    String? deliveryManName,
    Address? deliveryAddress,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    int? itemCount,
    String? storeName,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryManId: deliveryManId ?? this.deliveryManId,
      deliveryManName: deliveryManName ?? this.deliveryManName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      itemCount: itemCount ?? this.itemCount,
      storeName: storeName ?? this.storeName,
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle product image URL - ensure it's a complete URL
    String? productImage = json['product_image'];

    // If the image is just a filename, convert it to a full URL
    if (productImage != null && productImage.isNotEmpty) {
      // Check if it's already a full URL
      if (!productImage.startsWith('http')) {
        // Assuming your images are stored in the products directory
        // Update this base URL to match your server configuration
        productImage = '';
      }
    }

    return OrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      productImage: productImage,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zip_code'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    final components = [street, city, state, zipCode, country];
    return components.where((component) => component.isNotEmpty).join(', ');
  }

}
