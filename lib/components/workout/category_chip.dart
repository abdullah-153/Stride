import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../utils/size_config.dart';

class CategoryChip extends StatelessWidget {
  final WorkoutCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color.fromRGBO(206, 242, 75, 1);

    final bgColor = isSelected
        ? (isDarkMode ? Colors.white : Colors.black)
        : (isDarkMode ? const Color(0xFF2C2C2E) : Colors.white);

    final textColor = isSelected
        ? (isDarkMode ? Colors.black : Colors.white)
        : (isDarkMode ? Colors.white70 : Colors.black87);

    final borderColor = isSelected
        ? (isDarkMode ? Colors.white : Colors.black)
        : (isDarkMode ? Colors.white12 : Colors.grey.shade300);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: SizeConfig.w(8)),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(16),
          vertical: SizeConfig.h(10),
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(SizeConfig.w(12)),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          category.displayName,
          style: TextStyle(
            fontSize: SizeConfig.sp(14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class CategoryChipList extends StatelessWidget {
  final WorkoutCategory selectedCategory;
  final Function(WorkoutCategory) onCategorySelected;
  final bool isDarkMode;

  const CategoryChipList({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final categories = WorkoutCategory.values;

    return SizedBox(
      height: SizeConfig.h(40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            category: category,
            isSelected: selectedCategory == category,
            onTap: () => onCategorySelected(category),
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}
