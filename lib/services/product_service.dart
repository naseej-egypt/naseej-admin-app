import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiService.get(AppConstants.productsEndpoint);
      if (response['status'] == 'success' && response['data'] != null) {
        final productsData = response['data']['products'] as List;
        return productsData.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load products');
    } catch (e) {
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }

  Future<Product?> getProduct(String id) async {
    try {
      print('📡 API Request: /products/get_by_id.php');
      print('📡 Product ID: $id');
      print('📡 Base URL: ${AppConstants.apiBaseUrl}');

      final response = await _apiService.post(
        '/products/get_by_id.php',
        {'product_id': id},
      );

      print('📡 API Response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        print('✅ Product data received: ${response['data']['name']}');
        return Product.fromJson(response['data']);
      }

      print('❌ API returned no data or failed: ${response['message']}');
      return null;
    } catch (e) {
      print('❌ ERROR in getProduct: $e');
      throw Exception('Failed to load product: ${e.toString()}');
    }
  }

  Future<String> addProduct(Product product) async {
    try {
      final data = product.toFormData();

      for (int i = 0; i < product.colors.length; i++) {
        data['colors[$i]'] = product.colors[i];
      }

      for (int i = 0; i < product.sizes.length; i++) {
        data['sizes[$i]'] = product.sizes[i];
      }

      final response = await _apiService.post(
        '/products/add.php',
        data,
      );

      if (response['status'] == 'success') {
        return response['data']['id']?.toString() ?? '';
      }
      throw Exception(response['message'] ?? 'Failed to add product');
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final data = product.toFormData();
      data['product_id'] = product.id;

      for (int i = 0; i < product.colors.length; i++) {
        data['colors[$i]'] = product.colors[i];
      }

      for (int i = 0; i < product.sizes.length; i++) {
        data['sizes[$i]'] = product.sizes[i];
      }

      final response = await _apiService.post(
        '/products/update.php',
        data,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _apiService.post(
        '/products/delete.php',
        {'product_id': id},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  // NEW METHOD: Delete a single product image
  Future<void> deleteProductImage(String productId, String imageName) async {
    try {
      print('🗑️ Deleting image: $imageName from product: $productId');

      final response = await _apiService.post(
        '/products/delete_image.php',
        {
          'product_id': productId,
          'image_name': imageName,
        },
      );

      print('📡 Delete image response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete image');
      }

      print('✅ Image deleted successfully');
    } catch (e) {
      print('❌ Error deleting image: $e');
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  Future<String?> uploadProductImage(File image, String productId) async {
    try {
      final token = await ApiHelper.getToken();
      final uri =
      Uri.parse('${AppConstants.apiBaseUrl}/products/upload_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.fields['product_id'] = productId;
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['status'] == 'success') {
          final images = data['data']['images'] as List;
          return images.isNotEmpty ? images.first : null;
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiService.post(
        '/products/search.php',
        {'query': query},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final productsData = response['data']['products'] as List;
        return productsData.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final response = await _apiService.post(
        '/products/get_low_stock.php',
        {'threshold': threshold.toString()},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final productsData = response['data']['products'] as List;
        return productsData.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load low stock products: ${e.toString()}');
    }
  }

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      final response = await _apiService.post(
        '/products/toggle_status.php',
        {
          'product_id': productId,
          'is_active': isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(
            response['message'] ?? 'Failed to update product status');
      }
    } catch (e) {
      throw Exception('Failed to update product status: ${e.toString()}');
    }
  }

  Future<List<String>> uploadProductImages(
      List<File> images, String productId) async {
    try {
      final token = await ApiHelper.getToken();
      final uri =
      Uri.parse('${AppConstants.apiBaseUrl}/products/upload_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.fields['product_id'] = productId;

      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('file[]', image.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['status'] == 'success') {
          final images = List<String>.from(data['data']['images'] ?? []);
          return images;
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }
}