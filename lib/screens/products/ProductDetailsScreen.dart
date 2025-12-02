import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../widgets/custom_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductController productController = Get.find<ProductController>();
  bool isLoading = true;
  Product? product;
  int selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    final selectedProduct = productController.selectedProduct;

    if (selectedProduct == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No product selected'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      });
      return;
    }

    // Use the selected product directly first
    if (mounted) {
      setState(() {
        product = selectedProduct;
        isLoading = false;
      });
    }

    // Then optionally fetch fresh data in the background
    try {
      final fullProduct = await productController.getProductById(selectedProduct.id);
      if (fullProduct != null && mounted) {
        setState(() {
          product = fullProduct;
        });
      }
    } catch (e) {
      print('Failed to refresh product data: $e');
      // But keep showing the original product data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (product != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                productController.selectProduct(product!);
                Get.toNamed(AppRoutes.editProduct);
              },
            ),
          if (product != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        product!.isActive ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(product!.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      productController.toggleProductStatus(
                        product!.id,
                        !product!.isActive,
                      );
                    });
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
                    Future.delayed(Duration.zero, () => _showDeleteDialog());
                  },
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? const Center(child: Text('Product not found'))
          : _buildProductDetails(),
    );
  }

  Widget _buildProductDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          _buildImageGallery(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name & Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product!.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product!.isActive ? AppColors.success : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product!.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(
                      product!.categoryName ?? 'No Category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Section
                _buildPriceSection(),
                const SizedBox(height: 16),

                // Stock Status
                _buildStockSection(),
                const SizedBox(height: 24),

                // Colors Section
                if (product!.colors.isNotEmpty) ...[
                  _buildSectionHeader('Available Colors'),
                  const SizedBox(height: 12),
                  _buildColorsDisplay(),
                  const SizedBox(height: 24),
                ],

                // Sizes Section
                if (product!.sizes.isNotEmpty) ...[
                  _buildSectionHeader('Available Sizes'),
                  const SizedBox(height: 12),
                  _buildSizesDisplay(),
                  const SizedBox(height: 24),
                ],

                // Description
                _buildSectionHeader('Description'),
                const SizedBox(height: 8),
                Text(
                  product!.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Statistics
                if (product!.totalOrders != null) ...[
                  _buildSectionHeader('Statistics'),
                  const SizedBox(height: 12),
                  _buildStatistics(),
                  const SizedBox(height: 24),
                ],

                // Product Information
                _buildSectionHeader('Product Information'),
                const SizedBox(height: 12),
                _buildProductInfo(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        // Main Image
        Container(
          width: double.infinity,
          height: 400,
          color: AppColors.lightGrey,
          child: product!.images.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: product!.images[selectedImageIndex],
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.image_not_supported,
              size: 64,
              color: AppColors.grey,
            ),
          )
              : const Icon(
            Icons.image_not_supported,
            size: 64,
            color: AppColors.grey,
          ),
        ),

        // Thumbnails
        if (product!.images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product!.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImageIndex == index
                            ? AppColors.primary
                            : AppColors.grey,
                        width: selectedImageIndex == index ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: product!.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${product!.effectivePrice?.toStringAsFixed(2) ?? product!.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (product!.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${product!.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (product!.hasDiscount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${product!.discountPercentage?.toStringAsFixed(0) ?? product!.discountPercentage}% OFF',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockSection() {
    Color stockColor;
    String stockText;
    IconData stockIcon;

    if (product!.stock == 0) {
      stockColor = AppColors.error;
      stockText = 'Out of Stock';
      stockIcon = Icons.cancel;
    } else if (product!.stock <= 3) {
      stockColor = AppColors.error;
      stockText = 'Critical Stock: ${product!.stock} items';
      stockIcon = Icons.warning;
    } else if (product!.stock <= 10) {
      stockColor = AppColors.warning;
      stockText = 'Low Stock: ${product!.stock} items';
      stockIcon = Icons.info;
    } else {
      stockColor = AppColors.success;
      stockText = 'In Stock: ${product!.stock} items';
      stockIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(stockIcon, color: stockColor, size: 20),
          const SizedBox(width: 8),
          Text(
            stockText,
            style: TextStyle(
              color: stockColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsDisplay() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: product!.colors.map((color) {
        Color? colorValue = _getColorFromName(color);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorValue?.withOpacity(0.2) ?? AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorValue?.withOpacity(0.5) ?? AppColors.grey,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (colorValue != null)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              if (colorValue != null) const SizedBox(width: 8),
              Text(
                color,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizesDisplay() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product!.sizes.map((size) {
        return Chip(
          label: Text(size),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          labelStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Orders',
            '${product!.totalOrders ?? 0}',
            Icons.shopping_cart,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Quantity Sold',
            '${product!.totalQuantitySold ?? 0}',
            Icons.inventory_2,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Revenue',
            '\$${product!.revenue?.toStringAsFixed(2) ?? '0.00'}',
            Icons.attach_money,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Product ID', product!.id),
            const Divider(),
            _buildInfoRow('Category', product!.categoryName ?? 'N/A'),
            const Divider(),
            _buildInfoRow('Stock', '${product!.stock} items'),
            const Divider(),
            _buildInfoRow('Created', _formatDate(product!.createdAt)),
            if (product!.updatedAt != null) ...[
              const Divider(),
              _buildInfoRow('Last Updated', _formatDate(product!.updatedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Edit Product',
            onPressed: () {
              productController.selectProduct(product!);
              Get.toNamed(AppRoutes.editProduct);
            },
            icon: Icons.edit,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: product!.isActive ? 'Deactivate' : 'Activate',
            isOutlined: true,
            onPressed: () {
              productController.toggleProductStatus(
                product!.id,
                !product!.isActive,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color? _getColorFromName(String colorName) {
    final colorMap = {
      'Burgundy': const Color(0xFF800020),
      'Gold': const Color(0xFFFFD700),
      'Brown': const Color(0xFF8B4513),
      'Cream': const Color(0xFFFFFDD0),
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Black': Colors.black,
      'White': Colors.white,
      'Multi-color': Colors.grey,
    };
    return colorMap[colorName];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "${product!.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                productController.deleteProduct(product!.id);
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to products list
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}