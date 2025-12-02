import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/product.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../../widgets/color_size_selector.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final productController = Get.find<ProductController>();
  final categoryController = Get.find<CategoryController>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final discountPriceController = TextEditingController();
  final stockController = TextEditingController();

  String? selectedCategoryId;
  final List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isActive = true;
  bool _isSaving = false;

  // Color and Size management
  List<String> selectedColors = [];
  List<String> selectedSizes = [];

  // Predefined options
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
    if (categoryController.categories.isEmpty) {
      categoryController.loadCategories();
    }
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
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (pickedFiles != null) {
        setState(() {
          selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: ${e.toString()}');
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryId == null) {
      Get.snackbar('Error', 'Please select a category');
      return;
    }

    if (selectedImages.isEmpty) {
      Get.snackbar('Error', 'Please add at least one image');
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
      final category = categoryController.categories
          .firstWhere((cat) => cat.id == selectedCategoryId);

      final product = Product(
        id: '',
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        discountPrice: discountPriceController.text.isNotEmpty
            ? double.parse(discountPriceController.text)
            : null,
        stock: int.parse(stockController.text),
        categoryId: selectedCategoryId!,
        categoryName: category.name,
        images: [],
        colors: selectedColors,
        sizes: selectedSizes,
        isActive: isActive,
        createdAt: DateTime.now(),
      );

      final success = await productController.addProduct(product, selectedImages);

      if (success) {
        _navigateBackWithSuccess();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _navigateBackWithSuccess() {
    Get.snackbar(
      'Success',
      'Product added successfully!',
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
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              Text(
                'Product Images *',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...selectedImages.asMap().entries.map((entry) {
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
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
              if (selectedImages.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'At least one image is required',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),

              // Product Name
              CustomTextField(
                controller: nameController,
                label: 'Product Name *',
                hint: 'Enter product name',
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: descriptionController,
                label: 'Description *',
                hint: 'Enter product description',
                maxLines: 4,
                validator: Validators.validateDescription,
              ),
              const SizedBox(height: 16),

              // Category
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

              // Price
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

              // Stock
              CustomTextField(
                controller: stockController,
                label: 'Stock Quantity *',
                hint: '0',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.inventory),
                validator: Validators.validateStock,
              ),
              const SizedBox(height: 24),

              // Colors Section
              ColorSizeSelector(
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

              // Sizes Section
              ColorSizeSelector(
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

              // Active Status
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
                      text: 'Save Product',
                      onPressed: _isSaving ? null : _saveProduct,
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