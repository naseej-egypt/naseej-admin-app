import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../controllers/delivery_controller.dart';
import '../../models/delivery_man.dart';
import '../../services/delivery_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({super.key});

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final deliveryController = Get.find<DeliveryController>();
  final deliveryService = DeliveryService();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController vehicleTypeController;
  late TextEditingController vehicleNumberController;
  late TextEditingController passwordController;

  String? existingImageUrl;
  File? newImage;
  final ImagePicker _picker = ImagePicker();
  late String status;
  late bool isActive;
  bool isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final deliveryMan = deliveryController.selectedDeliveryMan;

    isEditMode = deliveryMan != null;
    nameController = TextEditingController(text: deliveryMan?.name ?? '');
    emailController = TextEditingController(text: deliveryMan?.email ?? '');
    phoneController = TextEditingController(text: deliveryMan?.phone ?? '');
    vehicleTypeController = TextEditingController(text: deliveryMan?.vehicleType ?? '');
    vehicleNumberController = TextEditingController(text: deliveryMan?.vehicleNumber ?? '');
    passwordController = TextEditingController();

    existingImageUrl = deliveryMan?.profileImage;
    status = deliveryMan?.status ?? 'available';
    isActive = deliveryMan?.isActive ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    vehicleTypeController.dispose();
    vehicleNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveDeliveryMan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      print('=== Saving Delivery Man ===');

      final deliveryMan = DeliveryMan(
        id: isEditMode ? deliveryController.selectedDeliveryMan!.id : '',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        profileImage: existingImageUrl,
        vehicleType: vehicleTypeController.text.trim(),
        vehicleNumber: vehicleNumberController.text.trim(),
        status: status,
        isActive: isActive,
        password: isEditMode ? null : passwordController.text.trim(), // Only set password for new delivery men
        rating: isEditMode ? deliveryController.selectedDeliveryMan!.rating : 0.0,
        totalDeliveries: isEditMode ? deliveryController.selectedDeliveryMan!.totalDeliveries : 0,
        createdAt: isEditMode ? deliveryController.selectedDeliveryMan!.createdAt : DateTime.now(),
      );

      bool success;
      if (isEditMode) {
        success = await deliveryController.updateDeliveryMan(deliveryMan, newImage);
      } else {
        success = await deliveryController.addDeliveryMan(deliveryMan, newImage);
      }

      if (success) {
        // Navigate immediately to delivery screen
        Get.offAllNamed('/delivery');
      }
    } catch (e) {
      print('Error in _saveDeliveryMan: $e');
      Get.snackbar(
        'Error',
        'Failed to save delivery person: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Delivery Person' : 'Add Delivery Person'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey, width: 2),
                      image: newImage != null
                          ? DecorationImage(
                        image: FileImage(newImage!),
                        fit: BoxFit.cover,
                      )
                          : existingImageUrl != null
                          ? DecorationImage(
                        image: NetworkImage(existingImageUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: newImage == null && existingImageUrl == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 32, color: AppColors.grey),
                        SizedBox(height: 8),
                        Text('Add Photo', style: TextStyle(color: AppColors.grey)),
                      ],
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              CustomTextField(
                controller: nameController,
                label: 'Full Name *',
                hint: 'Enter full name',
                prefixIcon: const Icon(Icons.person),
                validator: (value) => Validators.validateRequired(value, 'Name'),
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: emailController,
                label: 'Email *',
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                controller: phoneController,
                label: 'Phone Number *',
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 16),

              // Password (only for new delivery men)
              if (!isEditMode) ...[
                CustomTextField(
                  controller: passwordController,
                  label: 'Password *',
                  hint: 'Enter password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) => Validators.validateRequired(value, 'Password'),
                ),
                const SizedBox(height: 16),
              ],

              // Vehicle Type
              CustomTextField(
                controller: vehicleTypeController,
                label: 'Vehicle Type *',
                hint: 'e.g., Motorcycle, Car, Van',
                prefixIcon: const Icon(Icons.directions_car),
                validator: (value) => Validators.validateRequired(value, 'Vehicle type'),
              ),
              const SizedBox(height: 16),

              // Vehicle Number
              CustomTextField(
                controller: vehicleNumberController,
                label: 'Vehicle Number *',
                hint: 'Enter vehicle registration number',
                prefixIcon: const Icon(Icons.pin),
                validator: (value) => Validators.validateRequired(value, 'Vehicle number'),
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  prefixIcon: Icon(Icons.circle),
                ),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'busy', child: Text('Busy')),
                  DropdownMenuItem(value: 'offline', child: Text('Offline')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
                validator: (value) => Validators.validateRequired(value, 'Status'),
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Delivery person is active and can be assigned orders'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(height: 24),

              // Statistics (Edit mode only)
              if (isEditMode && deliveryController.selectedDeliveryMan != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistics',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 32),
                                const SizedBox(height: 4),
                                Text(
                                  deliveryController.selectedDeliveryMan!.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Rating'),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.delivery_dining, color: AppColors.primary, size: 32),
                                const SizedBox(height: 4),
                                Text(
                                  deliveryController.selectedDeliveryMan!.totalDeliveries.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Deliveries'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
                      text: isEditMode ? 'Update' : 'Add Delivery Person',
                      onPressed: _isSaving ? null : _saveDeliveryMan,
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