import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryController categoryController = Get.find<CategoryController>(); // FIX: Use Get.find instead of Get.put
  final searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => categoryController.loadCategories(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          categoryController.clearSelectedCategory();
          Get.toNamed(AppRoutes.categoryForm);
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
              label: 'Search Categories',
              hint: 'Search by name or description',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => categoryController.searchCategories(value),
            ),
          ),

          // Categories List
          Expanded(
            child: Obx(() {
              // Show loading only if we're actively loading and no categories exist
              if (categoryController.isLoading.value &&
                  categoryController.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show empty state only after initialization and no categories
              if (categoryController.filteredCategories.isEmpty && _isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        categoryController.searchQuery.value.isNotEmpty
                            ? 'No categories found matching your search'
                            : 'No categories found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (categoryController.searchQuery.value.isEmpty)
                        Text(
                          'Tap the "+" button to create your first category',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                );
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categoryController.filteredCategories.length,
                onReorder: (oldIndex, newIndex) {
                  if (categoryController.searchQuery.value.isNotEmpty) {
                    Get.snackbar(
                      'Info',
                      'Clear search to reorder categories',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final categories = List<Category>.from(categoryController.filteredCategories);
                  final item = categories.removeAt(oldIndex);
                  categories.insert(newIndex, item);
                  categoryController.reorderCategories(categories);
                },
                itemBuilder: (context, index) {
                  final category = categoryController.filteredCategories[index];
                  return Card(
                    key: ValueKey(category.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: category.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: category.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.lightGrey,
                            child: const Icon(Icons.image, color: AppColors.grey),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.lightGrey,
                            child: const Icon(Icons.broken_image, color: AppColors.grey),
                          ),
                        ),
                      )
                          : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category, color: AppColors.grey),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (category.productCount != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${category.productCount} products',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: category.isActive
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: category.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.primary),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                                onTap: () {
                                  categoryController.selectCategory(category);
                                  Future.delayed(
                                    Duration.zero,
                                        () => Get.toNamed(AppRoutes.categoryForm),
                                  );
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      category.isActive
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(category.isActive
                                        ? 'Deactivate'
                                        : 'Activate'),
                                  ],
                                ),
                                onTap: () {
                                  categoryController.toggleCategoryStatus(
                                    category.id,
                                    !category.isActive,
                                  );
                                },
                              ),
                              if (category.imageUrl != null)
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete_forever, color: AppColors.warning),
                                      SizedBox(width: 8),
                                      Text('Delete Image'),
                                    ],
                                  ),
                                  onTap: () {
                                    Future.delayed(
                                      Duration.zero,
                                          () => categoryController.deleteCategoryImage(category.id),
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
                                  Future.delayed(
                                    Duration.zero,
                                        () => _showDeleteDialog(category.id),
                                  );
                                },
                              ),
                            ],
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

  void _showDeleteDialog(String categoryId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This action cannot be undone.',
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
              categoryController.deleteCategory(categoryId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}