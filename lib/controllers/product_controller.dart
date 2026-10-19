import 'dart:io';
import '../utils/reactive.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/api_helper.dart';
import '../config/app_colors.dart';
import '../utils/constants.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  final products = <Product>[].obs;
  final filteredProducts = <Product>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  Product? selectedProduct;

  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
  }

  Future<Product?> getProductById(String id) async {
    try {
      isLoading.value = true;
      print('🔍 Fetching product with ID: $id');
      print('🔍 Base URL: ${AppConstants.apiBaseUrl}');

      final product = await _productService.getProduct(id);

      if (product == null) {
        print('❌ Product is NULL from service');
        Get.snackbar(
          'Error',
          'Product not found in database',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('✅ Product fetched successfully: ${product.name}');
        print('✅ Product colors: ${product.colors}');
        print('✅ Product sizes: ${product.sizes}');
      }

      return product;
    } catch (e) {
      print('❌ Error fetching product: $e');
      Get.snackbar(
        'Error',
        'Failed to load product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      if (products.isEmpty) {
        isLoading.value = true;
      }

      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final data = await _productService.getProducts();
      products.value = data;
      filteredProducts.value = data;
      _isFirstLoad = false;
      _hasLoaded = true;
    } catch (e) {
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('Product load error (first load): $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      _performBackendSearch(query);
    }
  }

  void _performBackendSearch(String query) async {
    try {
      isLoading.value = true;
      final results = await _productService.searchProducts(query);
      filteredProducts.value = results;
    } catch (e) {
      filteredProducts.value = products
          .where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where((product) => product.categoryId == categoryId)
          .toList();
    }
  }

  Future<bool> addProduct(Product product, List<File> images) async {
    try {
      isLoading.value = true;

      final productId = await _productService.addProduct(product);

      if (images.isNotEmpty) {
        await _productService.uploadProductImages(images, productId);
      }

      await loadProducts();

      Get.snackbar(
        'Success',
        'Product added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(Product product, List<File> newImages) async {
    try {
      isLoading.value = true;

      await _productService.updateProduct(product);

      if (newImages.isNotEmpty) {
        await _productService.uploadProductImages(newImages, product.id);
      }

      await loadProducts();

      Get.snackbar(
        'Success',
        'Product updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _productService.deleteProduct(productId);
      await loadProducts();
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // NEW METHOD: Delete a single product image
  Future<void> deleteProductImage(String productId, String imageName) async {
    try {
      await _productService.deleteProductImage(productId, imageName);

      // Update local product if it's selected
      if (selectedProduct?.id == productId) {
        final updatedImages = List<String>.from(selectedProduct!.images);
        updatedImages.removeWhere((img) => img.contains(imageName));
        selectedProduct = selectedProduct!.copyWith(images: updatedImages);
      }

      // Reload products to get fresh data
      await loadProducts();
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }

  Future<String?> uploadProductImage(File image, String productId) async {
    try {
      final url = await _productService.uploadProductImage(image, productId);
      return url;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  Future<void> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _productService.toggleProductStatus(productId, isActive);
      await loadProducts();
      Get.snackbar(
        'Success',
        'Product status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      return await _productService.getLowStockProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return [];
    }
  }

  void selectProduct(Product product) {
    selectedProduct = product;
  }

  void clearSelectedProduct() {
    selectedProduct = null;
  }

  List<Product> getProductsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  List<Product> get activeProducts {
    return products.where((product) => product.isActive).toList();
  }

  List<Product> get localLowStockProducts {
    return products.where((product) => product.isLowStock).toList();
  }

  bool get hasLoaded => _hasLoaded;
}