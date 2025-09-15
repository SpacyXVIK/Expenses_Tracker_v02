class Expense {
  final String id;
  final String payee;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? notes;

  Expense({
    required this.id,
    required this.payee,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'payee': payee,
        'amount': amount,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        'notes': notes,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        payee: json['payee'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        categoryId: json['categoryId'],
        notes: json['notes'],
      );
}
