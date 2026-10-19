import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductController productController = Get.find<ProductController>(); // FIX: Use Get.find
  final CategoryController categoryController = Get.find<CategoryController>(); // FIX: Use Get.find
  final searchController = TextEditingController();
  String? selectedCategoryFilter;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load products and categories when screen initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productController.products.isEmpty &&
          !productController.isLoading.value) {
        productController.loadProducts();
      }
      if (categoryController.categories.isEmpty &&
          !categoryController.isLoading.value) {
        categoryController.loadCategories();
      }
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => productController.loadProducts(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productController.clearSelectedProduct();
          Get.toNamed(AppRoutes.addProduct);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          // Search Bar - Full Width
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: CustomTextField(
              controller: searchController,
              label: 'Search Products',
              hint: 'Search by name or description',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => productController.searchProducts(value),
            ),
          ),

          // Category Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        'All Categories',
                        null,
                        selectedCategoryFilter == null,
                            () {
                          setState(() {
                            selectedCategoryFilter = null;
                          });
                          productController.filterByCategory(null);
                        },
                      ),
                      ...categoryController.categories.map(
                            (category) => _buildCategoryChip(
                          category.name,
                          category.id,
                          selectedCategoryFilter == category.id,
                              () {
                            setState(() {
                              selectedCategoryFilter = category.id;
                            });
                            productController.filterByCategory(category.id);
                          },
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Products List/Grid
          Expanded(
            child: Obx(() {
              // Show loading only if we're actively loading and no products exist
              if (productController.isLoading.value &&
                  productController.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show empty state only after initialization and no products
              if (productController.filteredProducts.isEmpty && _isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productController.searchQuery.value.isNotEmpty || selectedCategoryFilter != null
                            ? 'No products found matching your criteria'
                            : 'No products found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (productController.searchQuery.value.isEmpty && selectedCategoryFilter == null)
                        Text(
                          'Tap the "+" button to create your first product',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: productController.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = productController.filteredProducts[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(onTap: () {
                      print('Selected product: ${product.name} (ID: ${product.id})');
                      productController.selectProduct(product);
                      print('Controller selectedProduct: ${productController.selectedProduct?.name}');
                      Get.toNamed(AppRoutes.productDetails);
                    },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: AppColors.lightGrey,
                                  child: product.images.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: product.images.first,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: AppColors.grey,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: AppColors.grey,
                                  ),
                                ),
                                // Status Badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: product.isActive
                                          ? AppColors.success
                                          : AppColors.error,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product.isActive ? 'Active' : 'Inactive',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Low Stock Badge
                                if (product.isLowStock)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Low Stock',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Out of Stock Badge
                                if (product.isOutOfStock)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Out of Stock',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Product Info
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.categoryName ?? 'No Category',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '\$${product.effectivePrice.toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (product.hasDiscount)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: Text(
                                                    '\$${product.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: AppColors.grey,
                                                      fontSize: 12,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            'Stock: ${product.stock}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton(
                                        icon: const Icon(Icons.more_vert),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.visibility, color: AppColors.primary),
                                                SizedBox(width: 8),
                                                Text('View Details'),
                                              ],
                                            ),
                                            onTap: () {
                                              productController.selectProduct(product);
                                              Future.delayed(
                                                Duration.zero,
                                                    () => Get.toNamed(AppRoutes.productDetails),
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.edit, color: AppColors.primary),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                            onTap: () {
                                              productController.selectProduct(product);
                                              Future.delayed(
                                                Duration.zero,
                                                    () => Get.toNamed(AppRoutes.editProduct),
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  product.isActive
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: AppColors.accent,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(product.isActive
                                                    ? 'Deactivate'
                                                    : 'Activate'),
                                              ],
                                            ),
                                            onTap: () {
                                              productController.toggleProductStatus(
                                                product.id,
                                                !product.isActive,
                                              );
                                            },
                                          ),
                                          PopupMenuItem(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete, color: AppColors.error),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                            onTap: () {
                                              _showDeleteDialog(product.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: AppColors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  void _showDeleteDialog(String productId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              productController.deleteProduct(productId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}