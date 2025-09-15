import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final bool isDefault;
  final IconData icon; // Add this

  ExpenseCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.icon = Icons.category, // Default icon
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault,
      'iconCodePoint': icon.codePoint, // Store icon codePoint
      'iconFontFamily': icon.fontFamily,
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      isDefault: json['isDefault'] ?? false,
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
      ),
    );
  }
}
