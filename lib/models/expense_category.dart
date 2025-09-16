import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'expense_category.g.dart';

@HiveType(typeId: 1)
class ExpenseCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isDefault;

  @HiveField(3)
  final IconData icon;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.icon,
  });
}
