import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import 'package:naseej_admin_app/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileController = Get.put(ProfileController());
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  bool isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    // CRITICAL FIX: Force reload profile when screen opens
    print('📄 ProfileScreen opened - forcing profile reload');
    _profileController.loadProfile(forceRefresh: true);

    // Initialize controllers with empty values (will be updated when profile loads)
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Auto-upload image
        await _profileController.uploadProfileImage(_selectedImage!);
        setState(() {
          _selectedImage = null; // Clear after upload
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> _deleteImage() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Profile Image'),
        content: const Text('Are you sure you want to delete your profile image?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Get.back();
              await _profileController.deleteProfileImage();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await _profileController.updateProfile(
        nameController.text,
        phoneController.text,
      );

      if (success) {
        setState(() {
          isEditing = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      // Reset to original values
      final profile = _profileController.profile.value;
      if (profile != null) {
        nameController.text = profile.name;
        phoneController.text = profile.phoneNumber ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _profileController.refreshProfile(),
          ),
          Obx(() => _profileController.isLoading.value
              ? const SizedBox.shrink()
              : IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _cancelEdit();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          )),
        ],
      ),
      body: Obx(() {
        if (_profileController.isLoading.value && _profileController.profile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = _profileController.profile.value;
        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Failed to load profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _profileController.refreshProfile(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Debug log
        print('👤 ProfileScreen showing: ${profile.name} (ID: ${profile.id})');

        // Update controllers when profile loads
        if (nameController.text != profile.name) {
          nameController.text = profile.name;
          emailController.text = profile.email;
          phoneController.text = profile.phoneNumber ?? '';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePicture(profile),
              const SizedBox(height: 32),

              // Profile Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    CustomTextField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) => Validators.validateRequired(value, 'Name'),
                      enabled: isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Email Field (Read-only)
                    CustomTextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Your email',
                      prefixIcon: const Icon(Icons.email),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    CustomTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                      enabled: isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Role',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  profile.role.toUpperCase().replaceAll('_', ' '),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (isEditing) ...[
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                  isLoading: _profileController.isLoading.value,
                ),
                const SizedBox(height: 16),
              ],

              // Additional Options Card
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change Password'),
                      subtitle: const Text('You will be logged out after change'),
                      onTap: () {
                        Get.toNamed(AppRoutes.changePassword);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info, color: AppColors.primary),
                      title: const Text('About App'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Get.toNamed(AppRoutes.about),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Logout'),
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfilePicture(profile) {
    return Stack(
      children: [
        // Profile Picture
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : profile.profileImage != null
                ? Image.network(
              profile.profileImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primary,
                );
              },
            )
                : const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          ),
        ),

        // Edit Button
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: PopupMenuButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Upload Photo'),
                    ],
                  ),
                  onTap: _pickImage,
                ),
                if (profile.profileImage != null)
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete Photo'),
                      ],
                    ),
                    onTap: _deleteImage,
                  ),
              ],
            ),
          ),

        // Loading Overlay
        if (_profileController.isLoading.value && _selectedImage != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}