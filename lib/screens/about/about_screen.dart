import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import '../../config/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Icon/Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            // App Name and Version
            Text(
              'Naseej Admin',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Naseej Admin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Naseej Admin is a comprehensive administration panel designed for managing carpet and rug e-commerce operations. '
                          'This application provides complete control over products, orders, customers, and delivery operations.',
                      style: TextStyle(
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Features Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('Product Management'),
                    _buildFeatureItem('Order Processing'),
                    _buildFeatureItem('Customer Management'),
                    _buildFeatureItem('Delivery Tracking'),
                    _buildFeatureItem('Inventory Management'),
                    _buildFeatureItem('Sales Analytics'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact & Support',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      Icons.email,
                      'support@naseej.com',
                    ),
                    _buildContactItem(
                      Icons.phone,
                      '+966 123 456 789',
                    ),
                    _buildContactItem(
                      Icons.language,
                      'www.naseej.com',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Legal Information
            const Text(
              '© 2024 Naseej. All rights reserved.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}