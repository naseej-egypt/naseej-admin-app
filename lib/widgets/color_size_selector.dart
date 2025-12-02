import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ColorOption {
  final String name;
  final Color color;

  ColorOption(this.name, this.color);
}

class ColorSizeSelector extends StatefulWidget {
  final String title;
  final List<String> selectedItems;
  final List<ColorOption> predefinedOptions;
  final Function(List<String>) onSelectionChanged;
  final VoidCallback onAddCustom;
  final bool isColorSelector;

  const ColorSizeSelector({
    Key? key,
    required this.title,
    required this.selectedItems,
    required this.predefinedOptions,
    required this.onSelectionChanged,
    required this.onAddCustom,
    this.isColorSelector = false,
  }) : super(key: key);

  @override
  State<ColorSizeSelector> createState() => _ColorSizeSelectorState();
}

class _ColorSizeSelectorState extends State<ColorSizeSelector> {
  late List<String> _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = List<String>.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(ColorSizeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selection if parent changed it
    if (oldWidget.selectedItems != widget.selectedItems) {
      setState(() {
        _currentSelection = List<String>.from(widget.selectedItems);
      });
    }
  }

  void _toggleSelection(String item) {
    setState(() {
      if (_currentSelection.contains(item)) {
        _currentSelection.remove(item);
      } else {
        _currentSelection.add(item);
      }
    });
    widget.onSelectionChanged(_currentSelection);
  }

  void _removeCustomItem(String item) {
    setState(() {
      _currentSelection.remove(item);
    });
    widget.onSelectionChanged(_currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    // Find custom items (not in predefined options)
    final predefinedNames = widget.predefinedOptions.map((o) => o.name).toSet();
    final customItems =
    _currentSelection.where((item) => !predefinedNames.contains(item)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: widget.onAddCustom,
              icon: const Icon(Icons.add, size: 20),
              label: Text(widget.isColorSelector ? 'Add Color' : 'Add Size'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Predefined options
        if (widget.isColorSelector)
          _buildColorGrid()
        else
          _buildSizeChips(),

        // Custom items
        if (customItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Custom ${widget.isColorSelector ? 'Colors' : 'Sizes'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: customItems.map((item) {
              return Chip(
                label: Text(item),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                side: BorderSide(color: AppColors.primary),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeCustomItem(item),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],

        // Validation message
        if (_currentSelection.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'At least one ${widget.isColorSelector ? 'color' : 'size'} is required',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: widget.predefinedOptions.length,
      itemBuilder: (context, index) {
        final option = widget.predefinedOptions[index];
        final isSelected = _currentSelection.contains(option.name);

        return GestureDetector(
          onTap: () => _toggleSelection(option.name),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  color: option.color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  size: 24,
                )
                    : null,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  option.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSizeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.predefinedOptions.map((option) {
        final isSelected = _currentSelection.contains(option.name);
        return FilterChip(
          label: Text(option.name),
          selected: isSelected,
          onSelected: (_) => _toggleSelection(option.name),
          selectedColor: AppColors.primary,
          checkmarkColor: AppColors.white,
          backgroundColor: AppColors.lightGrey,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
