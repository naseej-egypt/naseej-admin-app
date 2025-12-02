import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DataTableWidget extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool isLoading;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          AppColors.primary.withOpacity(0.1),
        ),
        dataRowHeight: 60,
        headingRowHeight: 50,
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: columns
            .map(
              (column) => DataColumn(
            label: Text(
              column,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        )
            .toList(),
        rows: rows
            .map(
              (row) => DataRow(
            cells: row
                .map(
                  (cell) => DataCell(cell),
            )
                .toList(),
          ),
        )
            .toList(),
      ),
    );
  }
}