import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../../widgets/color_size_selector.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final productController = Get.find<ProductController>();
  final categoryController = Get.find<CategoryController>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController discountPriceController;
  late TextEditingController stockController;

  String? selectedCategoryId;
  List<String> existingImages = [];
  List<File> newImages = [];
  final ImagePicker _picker = ImagePicker();
  late bool isActive;
  bool _isSaving = false;

  List<String> selectedColors = [];
  List<String> selectedSizes = [];

  final List<ColorOption> colorOptions = [
    ColorOption('Burgundy', const Color(0xFF800020)),
    ColorOption('Gold', const Color(0xFFFFD700)),
    ColorOption('Brown', const Color(0xFF8B4513)),
    ColorOption('Cream', const Color(0xFFFFFDD0)),
    ColorOption('Multi-color', Colors.grey),
    ColorOption('Red', Colors.red),
    ColorOption('Blue', Colors.blue),
    ColorOption('Green', Colors.green),
    ColorOption('Black', Colors.black),
    ColorOption('White', Colors.white),
  ];

  final List<String> sizeOptions = [
    'Small (4x6 ft)',
    'Medium (6x9 ft)',
    'Large (8x10 ft)',
    'X-Large (9x12 ft)',
    'Runner (2x8 ft)',
    'Round (6 ft)',
  ];

  @override
  void initState() {
    super.initState();
    final product = productController.selectedProduct!;

    nameController = TextEditingController(text: product.name);
    descriptionController = TextEditingController(text: product.description);
    priceController = TextEditingController(text: product.price.toString());
    discountPriceController = TextEditingController(
      text: product.discountPrice?.toString() ?? '',
    );
    stockController = TextEditingController(text: product.stock.toString());

    selectedCategoryId = product.categoryId;
    existingImages = List.from(product.images);
    isActive = product.isActive;

    if (product.colors.isNotEmpty) {
      selectedColors = List<String>.from(product.colors.map((e) => e.toString().trim()));
    } else {
      selectedColors = [];
    }

    if (product.sizes.isNotEmpty) {
      selectedSizes = List<String>.from(product.sizes.map((e) => e.toString().trim()));
    } else {
      selectedSizes = [];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountPriceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    // Check current total images
    final totalImages = existingImages.length + newImages.length;
    if (totalImages >= 5) {
      Get.snackbar(
        'Error',
        'Maximum 5 images allowed per product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        final remainingSlots = 5 - totalImages;
        final filesToAdd = pickedFiles.take(remainingSlots).toList();

        if (pickedFiles.length > remainingSlots) {
          Get.snackbar(
            'Warning',
            'Only $remainingSlots image(s) added. Maximum 5 images allowed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.warning,
            colorText: AppColors.white,
          );
        }

        setState(() {
          newImages.addAll(filesToAdd.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
    }
  }

  Future<void> _removeExistingImage(int index) async {
    final imageUrl = existingImages[index];

    // Extract image filename from URL
    final imageName = imageUrl.split('/').last;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Call backend to delete image
      await productController.deleteProductImage(
        productController.selectedProduct!.id,
        imageName,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Update local state
      if (mounted) {
        setState(() {
          existingImages.removeAt(index);
        });
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete image: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  void _showColorPicker() {
    final customColorController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Custom Color'),
        content: TextField(
          controller: customColorController,
          decoration: const InputDecoration(
            labelText: 'Color Name',
            hintText: 'e.g., Navy Blue',
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customColorController.text.trim().isNotEmpty) {
                setState(() {
                  selectedColors.add(customColorController.text.trim());
                });
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSizePicker() {
    final customSizeController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Custom Size'),
        content: TextField(
          controller: customSizeController,
          decoration: const InputDecoration(
            labelText: 'Size Name',
            hintText: 'e.g., 10x12 ft',
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customSizeController.text.trim().isNotEmpty) {
                setState(() {
                  selectedSizes.add(customSizeController.text.trim());
                });
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryId == null) {
      Get.snackbar('Error', 'Please select a category');
      return;
    }

    if (existingImages.isEmpty && newImages.isEmpty) {
      Get.snackbar('Error', 'Product must have at least one image');
      return;
    }

    if (selectedColors.isEmpty) {
      Get.snackbar('Error', 'Please select at least one color');
      return;
    }

    if (selectedSizes.isEmpty) {
      Get.snackbar('Error', 'Please select at least one size');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final product = productController.selectedProduct!;
      final category = categoryController.categories
          .firstWhere((cat) => cat.id == selectedCategoryId);

      final updatedProduct = product.copyWith(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        discountPrice: discountPriceController.text.isNotEmpty
            ? double.parse(discountPriceController.text)
            : null,
        stock: int.parse(stockController.text),
        categoryId: selectedCategoryId,
        categoryName: category.name,
        images: existingImages,
        colors: selectedColors,
        sizes: selectedSizes,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      final success =
      await productController.updateProduct(updatedProduct, newImages);

      if (success) {
        _navigateBackWithSuccess();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _navigateBackWithSuccess() {
    Get.snackbar(
      'Success',
      'Product updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (Navigator.canPop(Get.context!)) {
        Navigator.pop(Get.context!);
      } else {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Image Picker
              Text(
                'Product Images * (${existingImages.length + newImages.length}/5)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...existingImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imageUrl = entry.value;
                      return Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey,
                                  child: const Icon(Icons.image,
                                      color: AppColors.grey),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey,
                                  child: const Icon(Icons.broken_image,
                                      color: AppColors.grey),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                  onPressed: () => _removeExistingImage(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    ...newImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                  onPressed: () => _removeNewImage(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (existingImages.length + newImages.length < 5)
                      InkWell(
                        onTap: _pickImages,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.grey),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 40, color: AppColors.grey),
                              SizedBox(height: 8),
                              Text('Add Images',
                                  style: TextStyle(color: AppColors.grey)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (existingImages.isEmpty && newImages.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'At least one image is required',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: nameController,
                label: 'Product Name *',
                hint: 'Enter product name',
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: descriptionController,
                label: 'Description *',
                hint: 'Enter product description',
                maxLines: 4,
                validator: Validators.validateDescription,
              ),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                value: selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select a category'),
                  ),
                  ...categoryController.categories
                      .where((cat) => cat.isActive)
                      .map((category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ))
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a category' : null,
              )),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: priceController,
                      label: 'Price *',
                      hint: '0.00',
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: Validators.validatePrice,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: discountPriceController,
                      label: 'Discount Price (Optional)',
                      hint: '0.00',
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.local_offer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: stockController,
                label: 'Stock Quantity *',
                hint: '0',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.inventory),
                validator: Validators.validateStock,
              ),
              const SizedBox(height: 24),

              ColorSizeSelector(
                key: ValueKey('color_selector_${selectedColors.join("_")}'),
                title: 'Available Colors *',
                selectedItems: selectedColors,
                predefinedOptions: colorOptions,
                onSelectionChanged: (colors) {
                  setState(() {
                    selectedColors = colors;
                  });
                },
                onAddCustom: _showColorPicker,
                isColorSelector: true,
              ),
              const SizedBox(height: 24),

              ColorSizeSelector(
                key: ValueKey('size_selector_${selectedSizes.join("_")}'),
                title: 'Available Sizes *',
                selectedItems: selectedSizes,
                predefinedOptions:
                sizeOptions.map((s) => ColorOption(s, Colors.grey)).toList(),
                onSelectionChanged: (sizes) {
                  setState(() {
                    selectedSizes = sizes;
                  });
                },
                onAddCustom: _showSizePicker,
                isColorSelector: false,
              ),
              const SizedBox(height: 24),

              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Product is visible to customers'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(height: 24),

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
                      text: 'Update Product',
                      onPressed: _isSaving ? null : _updateProduct,
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