import 'package:hive/hive.dart';

part 'recurring_expense.g.dart';

@HiveType(typeId: 3)
class RecurringExpense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String payee;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String frequency; // 'monthly', 'weekly', 'yearly'

  @HiveField(6)
  final DateTime nextDueDate;

  @HiveField(7)
  final bool isActive;

  RecurringExpense({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.payee,
    this.notes,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
  });

  // ✅ copyWith for updating fields easily
  RecurringExpense copyWith({
    String? id,
    String? categoryId,
    double? amount,
    String? payee,
    String? notes,
    String? frequency,
    DateTime? nextDueDate,
    bool? isActive,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      payee: payee ?? this.payee,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
    );
  }
}