import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> chartData;
  final String chartType;
  final double width;

  const ChartCard({
    Key? key,
    required this.title,
    required this.chartData,
    required this.chartType,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final labels = List<String>.from(chartData['labels'] ?? []);
    final values = List<dynamic>.from(chartData['revenue'] ?? chartData['orders'] ?? []);

    if (labels.isEmpty || values.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    if (chartType == 'pie') {
      return _buildPieChart(labels, values);
    } else {
      return _buildBarChart(labels, values);
    }
  }

  Widget _buildBarChart(List<String> labels, List<dynamic> values) {
    // Convert values to double and find max value
    final doubleValues = values.map((v) => (v is int ? v.toDouble() : v as double)).toList();
    final maxValue = doubleValues.isNotEmpty
        ? doubleValues.reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(labels.length, (index) {
        return Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final value = doubleValues[index];
            final height = maxValue > 0 ? (value / maxValue) * constraints.maxHeight * 0.8 : 0.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  height: height,
                  decoration: BoxDecoration(
                    color: _getChartColor(index),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }),
        );
      }),
    );
  }

  Widget _buildPieChart(List<String> labels, List<dynamic> values) {
    // Convert values to double and calculate total
    final doubleValues = values.map((v) => (v is int ? v.toDouble() : v as double)).toList();
    final total = doubleValues.fold(0.0, (sum, value) => sum + value);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple pie chart representation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                '${labels.length} Items',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(labels.length, (index) {
            if (index >= 3) return const SizedBox.shrink(); // Show only top 3
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: _getChartColor(index),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${((doubleValues[index]) / total * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getChartColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
      AppColors.accent,
    ];
    return colors[index % colors.length];
  }
}