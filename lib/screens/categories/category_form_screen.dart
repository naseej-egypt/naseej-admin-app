import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final categoryController = Get.find<CategoryController>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;

  String? existingImageUrl;
  File? newImage;
  final ImagePicker _picker = ImagePicker();
  late bool isActive;
  bool isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final category = categoryController.selectedCategory;

    isEditMode = category != null;
    nameController = TextEditingController(text: category?.name ?? '');
    descriptionController = TextEditingController(text: category?.description ?? '');
    existingImageUrl = category?.imageUrl;
    isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          newImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Create category object
      final category = Category(
        id: isEditMode ? categoryController.selectedCategory!.id : '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        imageUrl: existingImageUrl,
        isActive: isActive,
        order: isEditMode ? categoryController.selectedCategory!.order : categoryController.categories.length,
        createdAt: isEditMode ? categoryController.selectedCategory!.createdAt : DateTime.now(),
      );

      bool success = false;
      String? newCategoryId;

      if (isEditMode) {
        print('Updating category...');
        success = await categoryController.updateCategory(category);
        print('Update result: $success');

        if (success && newImage != null) {
          print('Uploading new image for update...');
          await categoryController.uploadCategoryImage(newImage!, category.id);
          await categoryController.loadCategories();
        }
      } else {
        print('Adding new category...');
        newCategoryId = await categoryController.addCategory(category);
        print('Add result: $newCategoryId');

        if (newCategoryId != null && newImage != null) {
          print('Uploading image for new category...');
          await categoryController.uploadCategoryImage(newImage!, newCategoryId);
          await categoryController.loadCategories();
        }
        success = newCategoryId != null;
      }

      if (success) {
        print('Operation successful, showing success message...');

        // Option 1: Use Navigator instead of Get.back()
        _navigateBackWithSuccess();

      } else {
        print('Operation failed');
      }
    } catch (e) {
      print('Error in _saveCategory: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _navigateBackWithSuccess() {
    // Show success message
    Get.snackbar(
      'Success',
      isEditMode ? 'Category updated successfully!' : 'Category added successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );

    // Use multiple navigation approaches to ensure we go back

    // Approach 1: Use Navigator with a small delay
    Future.delayed(const Duration(milliseconds: 2200), () {
      print('Attempting navigation with Navigator...');
      if (Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
        print('Navigator.pop completed');
      } else {
        print('Cannot pop with Navigator, trying Get.back...');
        Get.back();
      }
    });

    // Approach 2: Backup approach with Get.until
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      if (Get.isSnackbarOpen == true) {
        Get.back();
      }

      // Force navigation back to categories
      print('Force navigating back...');
      Get.until((route) {
        print('Current route: ${Get.currentRoute}');
        return Get.currentRoute == '/categories' ||
            Get.currentRoute.contains('categories');
      });
    });
  }

  void _removeImage() {
    setState(() {
      newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              Text(
                'Category Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: newImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          newImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                          : existingImageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: existingImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48),
                              SizedBox(height: 8),
                              Text('Failed to load image'),
                            ],
                          ),
                        ),
                      )
                          : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: AppColors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add category image'),
                        ],
                      ),
                    ),
                  ),
                  if (newImage != null || existingImageUrl != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.white, size: 20),
                          onPressed: _removeImage,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Name
              CustomTextField(
                controller: nameController,
                label: 'Category Name *',
                hint: 'Enter category name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category name is required';
                  }
                  if (value.length < 2) {
                    return 'Category name must be at least 2 characters';
                  }
                  if (value.length > 100) {
                    return 'Category name is too long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: descriptionController,
                label: 'Description *',
                hint: 'Enter category description',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Category is visible to customers'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(height: 24),

              // Save Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: _isSaving ? null : () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: isEditMode ? 'Update Category' : 'Save Category',
                      onPressed: _isSaving ? null : _saveCategory,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}