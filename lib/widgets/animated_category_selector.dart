import 'package:flutter/material.dart';
import '../models/expense_category.dart';

class AnimatedCategorySelector extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final Function(ExpenseCategory) onSelect;
  final ExpenseCategory? selectedCategory;

  const AnimatedCategorySelector({
    Key? key,
    required this.categories,
    required this.onSelect,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<AnimatedCategorySelector> createState() => _AnimatedCategorySelectorState();
}

class _AnimatedCategorySelectorState extends State<AnimatedCategorySelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = widget.selectedCategory?.id == category.id;

          return TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              begin: 0,
              end: isSelected ? 1.0 : 0.0,
            ),
            builder: (context, double value, child) {
              return GestureDetector(
                onTap: () => widget.onSelect(category),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      Theme.of(context).cardColor,
                      Theme.of(context).primaryColor,
                      value,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.0 + (value * 0.2),
                        child: Icon(
                          category.icon,
                          color: Color.lerp(
                            Theme.of(context).iconTheme.color,
                            Colors.white,
                            value,
                          ),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: Color.lerp(
                            Theme.of(context).textTheme.bodyLarge?.color,
                            Colors.white,
                            value,
                          ),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}