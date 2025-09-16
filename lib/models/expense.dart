import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String payee;

  @HiveField(5)
  final String? notes;

  Expense({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.payee,
    this.notes,
  });
}
