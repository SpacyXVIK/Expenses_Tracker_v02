import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class MonthlyBudgetWidget extends StatelessWidget {
  const MonthlyBudgetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final monthlyExpenses = expenseProvider.getMonthlyExpenseTotal();
        final budget = expenseProvider.monthlyBudget;
        final progress = budget > 0 ? (monthlyExpenses / budget) : 0.0;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showBudgetDialog(context, expenseProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Spent: Rs. ${monthlyExpenses.toStringAsFixed(2)} / Rs. ${budget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Budget Amount',
            prefixText: 'Rs.',
            errorText: _validateAmount(controller.text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 0) {
                provider.setMonthlyBudget(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String? _validateAmount(String value) {
    if (value.isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(value);
    if (amount == null) return 'Please enter a valid number';
    if (amount < 0) return 'Amount cannot be negative';
    return null;
  }
}