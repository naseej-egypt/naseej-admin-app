import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/admin_controller.dart';
import '../../utils/validators.dart';

class AdminDetailsScreen extends StatefulWidget {
  const AdminDetailsScreen({super.key});

  @override
  State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  final adminController = Get.find<AdminController>();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late String selectedRole;
  late bool isActive;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final admin = adminController.selectedAdmin!;
    nameController = TextEditingController(text: admin.name);
    phoneController = TextEditingController(text: admin.phoneNumber ?? '');
    selectedRole = admin.role;
    isActive = admin.isActive;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // FIXED: Simplified save admin with direct navigation back to admins screen
  Future<void> _saveAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final admin = adminController.selectedAdmin!;
      final updatedAdmin = admin.copyWith(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        role: selectedRole,
        isActive: isActive,
      );

      print('💾 Attempting to save admin: ${updatedAdmin.name}');

      final success = await adminController.updateAdmin(updatedAdmin);

      if (success) {
        print('✅ Admin updated successfully');

        // FIXED: Navigate back first, then show success message
        Get.back(); // Go back to admins screen

        // Show success message on the admins screen
        Get.snackbar(
          'Success',
          'Admin updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: AppColors.white),
        );
      }
    } catch (e) {
      print('❌ Save error: $e');
      Get.snackbar(
        'Error',
        'Failed to update admin: ${e.toString().replaceAll("Exception:", "").trim()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = adminController.selectedAdmin!;

    return WillPopScope(
      onWillPop: () async {
        if (_isEditing && !_isSaving) {
          // Show confirmation dialog if editing
          return await _showDiscardChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Details'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _isSaving
                    ? null
                    : () async {
                  final shouldDiscard = await _showDiscardChangesDialog();
                  if (shouldDiscard) {
                    setState(() {
                      _isEditing = false;
                      // Reset form
                      nameController.text = admin.name;
                      phoneController.text = admin.phoneNumber ?? '';
                      selectedRole = admin.role;
                      isActive = admin.isActive;
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveAdmin,
              ),
            ],
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: admin.profileImage != null
                              ? NetworkImage(admin.profileImage!)
                              : null,
                          child: admin.profileImage == null
                              ? Text(
                            admin.initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          admin.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: admin.isActive
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            admin.isActive ? 'Active Admin' : 'Inactive Admin',
                            style: TextStyle(
                              color: admin.isActive ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Contact Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_isEditing)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Editing',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.email,
                          'Email',
                          admin.email,
                          isEditable: false,
                        ),
                        const SizedBox(height: 12),
                        _buildEditableInfoRow(
                          Icons.person,
                          'Name',
                          nameController,
                          validator: (value) => Validators.validateRequired(value, 'Name'),
                        ),
                        const SizedBox(height: 12),
                        _buildEditableInfoRow(
                          Icons.phone,
                          'Phone',
                          phoneController,
                          validator: Validators.validatePhone,
                        ),
                        const SizedBox(height: 12),

                        // Role Selection
                        const Text(
                          'Role',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            isDense: true,
                            enabled: _isEditing,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'manager',
                              child: Text('Manager'),
                            ),
                          ],
                          onChanged: _isEditing
                              ? (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          }
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Status Toggle
                        SwitchListTile(
                          title: const Text('Active Status'),
                          subtitle: const Text('Admin can access the system'),
                          value: isActive,
                          onChanged: _isEditing
                              ? (value) {
                            setState(() {
                              isActive = value;
                            });
                          }
                              : null,
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Account Information
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Member Since',
                          _formatDate(admin.createdAt),
                          isEditable: false,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.history,
                          'Last Login',
                          admin.lastLogin != null ? _formatDate(admin.lastLogin!) : 'Never',
                          isEditable: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () async {
                            final shouldDiscard = await _showDiscardChangesDialog();
                            if (shouldDiscard) {
                              setState(() {
                                _isEditing = false;
                                // Reset form
                                nameController.text = admin.name;
                                phoneController.text = admin.phoneNumber ?? '';
                                selectedRole = admin.role;
                                isActive = admin.isActive;
                              });
                            }
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSaving ? null : _saveAdmin,
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDiscardChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Discard'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isEditable = true}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoRow(
      IconData icon,
      String label,
      TextEditingController controller, {
        String? Function(String?)? validator,
      }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: controller,
                enabled: _isEditing,
                validator: validator,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}