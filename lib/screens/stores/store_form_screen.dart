import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../controllers/store_controller.dart';
import '../../models/store.dart';
import '../../services/store_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class StoreFormScreen extends StatefulWidget {
  const StoreFormScreen({super.key});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final storeController = Get.find<StoreController>();
  final storeService = StoreService();

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late TextEditingController managerNameController;
  late TextEditingController managerPhoneController;

  String? existingImageUrl;
  File? newImage;
  final ImagePicker _picker = ImagePicker();
  late bool isActive;
  bool isEditMode = false;
  bool _isSaving = false;

  // UPDATED: Default to 9 AM - 3 AM (overnight operation)
  TimeOfDay openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closingTime = const TimeOfDay(hour: 3, minute: 0);

  // FIXED: Use Set to prevent duplicates
  Set<String> workingDaysSet = {};
  bool _workingDaysError = false;

  // All available days
  final List<String> allDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final store = storeController.selectedStore;

    isEditMode = store != null;
    nameController = TextEditingController(text: store?.name ?? '');
    addressController = TextEditingController(text: store?.address ?? '');
    phoneController = TextEditingController(text: store?.phone ?? '');
    emailController = TextEditingController(text: store?.email ?? '');
    latitudeController = TextEditingController(text: store?.latitude.toString() ?? '24.7136');
    longitudeController = TextEditingController(text: store?.longitude.toString() ?? '46.6753');
    managerNameController = TextEditingController(text: store?.managerName ?? '');
    managerPhoneController = TextEditingController(text: store?.managerPhone ?? '');

    existingImageUrl = store?.imageUrl;
    isActive = store?.isActive ?? true;

    if (store != null) {
      openingTime = store.openingTime;
      closingTime = store.closingTime;
      // FIXED: Load working days into Set
      workingDaysSet = Set.from(store.workingDays);

      print('=== Loading Store Data ===');
      print('Working days from store: ${store.workingDays}');
      print('Working days set: $workingDaysSet');
      // REMOVED: Time formatting from initState - will be done in didChangeDependencies
      print('Opening time: $openingTime');
      print('Closing time: $closingTime');
      print('Is currently open: ${store.isCurrentlyOpen}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now context is available, we can safely format times for logging
    if (storeController.selectedStore != null) {
      print('Formatted Opening time: ${openingTime.format(context)}');
      print('Formatted Closing time: ${closingTime.format(context)}');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    managerNameController.dispose();
    managerPhoneController.dispose();
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

  Future<void> _selectOpeningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: openingTime,
    );
    if (picked != null) {
      setState(() {
        openingTime = picked;
        // Log the change
        print('Opening time changed to: ${openingTime.format(context)}');
        print('New store status would be: ${_calculateStoreStatus()}');
      });
    }
  }

  Future<void> _selectClosingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: closingTime,
    );
    if (picked != null) {
      setState(() {
        closingTime = picked;
        // Log the change
        print('Closing time changed to: ${closingTime.format(context)}');
        print('New store status would be: ${_calculateStoreStatus()}');
      });
    }
  }

  // Helper method to calculate current store status based on selected times
  String _calculateStoreStatus() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentDay = _getCurrentDay();

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    bool isOpen = false;

    if (workingDaysSet.contains(currentDay)) {
      // If closing time is earlier than opening time (overnight operation)
      if (closingMinutes < openingMinutes) {
        // Store is open if current time is after opening OR before closing (next day)
        isOpen = currentMinutes >= openingMinutes || currentMinutes <= closingMinutes;
      } else {
        // Normal operation (same day)
        isOpen = currentMinutes >= openingMinutes && currentMinutes <= closingMinutes;
      }
    }

    return isOpen ? 'Open' : 'Closed';
  }

  // Helper method to get current day without using context
  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[now.weekday - 1]; // DateTime.weekday returns 1-7 (Monday=1)
  }

  // Format time for display without context dependency
  String _formatTimeForDisplay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    if (time.hour < 5) { // If time is between midnight and 5 AM, show as next day
      return '$hour:$minute (next day)';
    } else {
      return '$hour:$minute';
    }
  }

  // FIXED: Toggle day in Set (prevents duplicates)
  void _toggleWorkingDay(String day) {
    setState(() {
      if (workingDaysSet.contains(day)) {
        workingDaysSet.remove(day);
      } else {
        workingDaysSet.add(day);
      }
      _workingDaysError = false;

      print('=== Toggled Day: $day ===');
      print('Working days set: $workingDaysSet');
      print('New store status would be: ${_calculateStoreStatus()}');
    });
  }

  bool _validateForm() {
    final areTextFieldsValid = _formKey.currentState!.validate();
    final areWorkingDaysValid = workingDaysSet.isNotEmpty;

    setState(() {
      _workingDaysError = !areWorkingDaysValid;
    });

    if (!areWorkingDaysValid) {
      Get.snackbar(
        'Error',
        'Please select at least one working day',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    return areTextFieldsValid;
  }

  Future<void> _saveStore() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // FIXED: Convert Set to List
      final workingDaysList = workingDaysSet.toList();

      print('=== Saving Store ===');
      print('Working days set: $workingDaysSet');
      print('Working days list: $workingDaysList');
      print('Opening time: ${openingTime.format(context)}');
      print('Closing time: ${closingTime.format(context)}');
      print('Store would be: ${_calculateStoreStatus()}');

      final store = Store(
        id: isEditMode ? storeController.selectedStore!.id : '',
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        imageUrl: existingImageUrl,
        isActive: isActive,
        managerName: managerNameController.text.trim(),
        managerPhone: managerPhoneController.text.trim(),
        openingTime: openingTime,
        closingTime: closingTime,
        workingDays: workingDaysList, // Use the list from Set
        createdAt: isEditMode ? storeController.selectedStore!.createdAt : DateTime.now(),
      );

      bool success;
      if (isEditMode) {
        success = await storeController.updateStore(store, newImage);
      } else {
        success = await storeController.addStore(store, newImage);
      }

      if (success) {
        // Navigate immediately to stores screen
        // The success snackbar is now handled by the StoreController
        Get.offAllNamed('/stores'); // This ensures we go back to stores screen
      }
    } catch (e) {
      print('Error in _saveStore: $e');
      Get.snackbar(
        'Error',
        'Failed to save store: ${e.toString()}',
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
        title: Text(isEditMode ? 'Edit Store' : 'Add New Store'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Image
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.add_photo_alternate, size: 32, color: AppColors.grey),
                        SizedBox(height: 8),
                        Text('Add Store Image', style: TextStyle(color: AppColors.grey)),
                      ],
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Store Name
              CustomTextField(
                controller: nameController,
                label: 'Store Name *',
                hint: 'Enter store name',
                prefixIcon: const Icon(Icons.store),
                validator: (value) => Validators.validateRequired(value, 'Store name'),
              ),
              const SizedBox(height: 16),

              // Address
              CustomTextField(
                controller: addressController,
                label: 'Address *',
                hint: 'Enter store address',
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 2,
                validator: (value) => Validators.validateRequired(value, 'Address'),
              ),
              const SizedBox(height: 16),

              // Contact Information
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: phoneController,
                      label: 'Phone *',
                      hint: 'Store phone number',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: emailController,
                      label: 'Email *',
                      hint: 'Store email',
                      prefixIcon: const Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Coordinates
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: latitudeController,
                      label: 'Latitude *',
                      hint: 'e.g., 24.7136',
                      prefixIcon: const Icon(Icons.explore),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => Validators.validateRequired(value, 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: longitudeController,
                      label: 'Longitude *',
                      hint: 'e.g., 46.6753',
                      prefixIcon: const Icon(Icons.explore),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => Validators.validateRequired(value, 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Manager Information
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: managerNameController,
                      label: 'Manager Name *',
                      hint: 'Store manager name',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) => Validators.validateRequired(value, 'Manager name'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: managerPhoneController,
                      label: 'Manager Phone *',
                      hint: 'Manager phone number',
                      prefixIcon: const Icon(Icons.phone_android),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Operating Hours - UPDATED with status preview
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Opening Time *'),
                      subtitle: Text(openingTime.format(context)), // Safe to use context here in build
                      leading: const Icon(Icons.access_time),
                      onTap: _selectOpeningTime,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Closing Time *'),
                      subtitle: Text(_formatTimeForDisplay(closingTime)), // Use our custom formatter
                      leading: const Icon(Icons.access_time),
                      onTap: _selectClosingTime,
                    ),
                  ),
                ],
              ),
              // Status preview
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'With these hours, store would be: ${_calculateStoreStatus()}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Working Days Section - FIXED
              Container(
                decoration: _workingDaysError
                    ? BoxDecoration(
                  border: Border.all(color: AppColors.error, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.error.withOpacity(0.05),
                )
                    : null,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Working Days *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _workingDaysError ? AppColors.error : null,
                          ),
                        ),
                        if (_workingDaysError)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '(Please select at least one day)',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allDays.map((day) {
                        final isSelected = workingDaysSet.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (_) => _toggleWorkingDay(day),
                          selectedColor: AppColors.primary,
                          checkmarkColor: AppColors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Active Store'),
                subtitle: const Text('Store is active and visible to customers'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(height: 32),

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
                      text: isEditMode ? 'Update Store' : 'Add Store',
                      onPressed: _isSaving ? null : _saveStore,
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