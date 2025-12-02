import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final int stock;
  final String categoryId;
  final String? categoryName;
  final List<String> images;
  final List<String> colors;
  final List<String> sizes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? specifications;

  // Additional fields for product details
  final int? totalOrders;
  final int? totalQuantitySold;
  final double? revenue;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.categoryId,
    this.categoryName,
    required this.images,
    required this.colors,
    required this.sizes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.specifications,
    this.totalOrders,
    this.totalQuantitySold,
    this.revenue,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is String) {
        try {
          final decoded = jsonDecode(json['images']);
          if (decoded is List) {
            imagesList = List<String>.from(decoded);
          } else {
            imagesList = json['images'].split(',');
          }
        } catch (e) {
          imagesList = [json['images']];
        }
      } else if (json['images'] is List) {
        imagesList = List<String>.from(json['images']);
      }
    }

    // Parse colors with extensive debugging
    List<String> colorsList = [];
    if (json['colors'] != null) {
      print('🎨 DEBUG Product.fromJson - colors field type: ${json['colors'].runtimeType}');
      print('🎨 DEBUG Product.fromJson - colors raw value: ${json['colors']}');

      if (json['colors'] is String) {
        try {
          final decoded = jsonDecode(json['colors']);
          print('🎨 DEBUG - Decoded colors: $decoded (type: ${decoded.runtimeType})');
          if (decoded is List) {
            colorsList = List<String>.from(decoded.map((e) => e.toString().trim()));
            print('🎨 DEBUG - Final colorsList: $colorsList');
          }
        } catch (e) {
          print('❌ ERROR parsing colors JSON: $e');
          colorsList = [];
        }
      } else if (json['colors'] is List) {
        colorsList = List<String>.from(json['colors'].map((e) => e.toString().trim()));
        print('🎨 DEBUG - Colors from List: $colorsList');
      }
    } else {
      print('⚠️ WARNING: colors field is NULL');
    }

    // Parse sizes with extensive debugging
    List<String> sizesList = [];
    if (json['sizes'] != null) {
      print('📏 DEBUG Product.fromJson - sizes field type: ${json['sizes'].runtimeType}');
      print('📏 DEBUG Product.fromJson - sizes raw value: ${json['sizes']}');

      if (json['sizes'] is String) {
        try {
          final decoded = jsonDecode(json['sizes']);
          print('📏 DEBUG - Decoded sizes: $decoded (type: ${decoded.runtimeType})');
          if (decoded is List) {
            sizesList = List<String>.from(decoded.map((e) => e.toString().trim()));
            print('📏 DEBUG - Final sizesList: $sizesList');
          }
        } catch (e) {
          print('❌ ERROR parsing sizes JSON: $e');
          sizesList = [];
        }
      } else if (json['sizes'] is List) {
        sizesList = List<String>.from(json['sizes'].map((e) => e.toString().trim()));
        print('📏 DEBUG - Sizes from List: $sizesList');
      }
    } else {
      print('⚠️ WARNING: sizes field is NULL');
    }

    // Parse specifications
    Map<String, dynamic>? specifications;
    if (json['specifications'] != null) {
      if (json['specifications'] is String) {
        try {
          specifications = Map<String, dynamic>.from(jsonDecode(json['specifications']));
        } catch (e) {
          specifications = null;
        }
      } else if (json['specifications'] is Map) {
        specifications = Map<String, dynamic>.from(json['specifications']);
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice: json['discount_price'] != null
          ? double.tryParse(json['discount_price'].toString())
          : null,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'],
      images: imagesList,
      colors: colorsList,
      sizes: sizesList,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      specifications: specifications,
      totalOrders: json['statistics'] != null ? json['statistics']['total_orders'] : null,
      totalQuantitySold: json['statistics'] != null ? json['statistics']['total_quantity_sold'] : null,
      revenue: json['statistics'] != null ? double.tryParse(json['statistics']['revenue']?.toString() ?? '0') : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'category_id': categoryId,
      'category_name': categoryName,
      'images': jsonEncode(images),
      'colors': jsonEncode(colors),
      'sizes': jsonEncode(sizes),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'specifications': specifications != null ? jsonEncode(specifications) : null,
    };
  }

  // For form data submission
  Map<String, dynamic> toFormData() {
    return {
      'name': name,
      'description': description,
      'price': price.toString(),
      'discount_price': discountPrice?.toString() ?? '',
      'stock': stock.toString(),
      'category_id': categoryId,
      'is_active': isActive ? '1' : '0',
      // Don't include colors and sizes here - they'll be added separately as arrays
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    int? stock,
    String? categoryId,
    String? categoryName,
    List<String>? images,
    List<String>? colors,
    List<String>? sizes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specifications: specifications ?? this.specifications,
    );
  }

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100);
  }
  bool get inStock => stock > 0;
  bool get isLowStock => stock <= 10 && stock > 0;
  bool get isOutOfStock => stock == 0;
  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
}
