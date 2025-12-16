import 'package:flutter/material.dart';

class PremiumSelector<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T selectedValue;
  final Function(T) onSelected;
  final String Function(T) itemLabelBuilder;
  final bool isDarkMode;

  const PremiumSelector({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.itemLabelBuilder,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: subTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final isSelected = item == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent.shade700
                      : (isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDarkMode ? Colors.white10 : Colors.black12),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  itemLabelBuilder(item),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
