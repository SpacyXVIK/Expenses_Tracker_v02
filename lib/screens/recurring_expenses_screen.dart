import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/recurring_expense.dart';

class RecurringExpensesScreen extends StatelessWidget {
  const RecurringExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Expenses'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            itemCount: provider.recurringExpenses.length,
            itemBuilder: (context, index) {
              final recurring = provider.recurringExpenses[index];
              return ListTile(
                title: Text('${recurring.payee} - Rs. ${recurring.amount}'),
                subtitle: Text(
                  'Every ${recurring.frequency} - Next due: ${recurring.nextDueDate.toString().split(' ')[0]}',
                ),
                trailing: Switch(
                  value: recurring.isActive,
                  onChanged: (value) {
                    provider.updateRecurringExpense(
                      recurring.copyWith(isActive: value),
                    );
                  },
                ),
                onLongPress: () => _showDeleteDialog(
                  context,
                  recurring.payee,
                  () => provider.deleteRecurringExpense(recurring.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddRecurringExpenseDialog(context),
      ),
    );
  }

  // ✅ Delete Dialog
  void _showDeleteDialog(
      BuildContext context, String itemName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $itemName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.of(ctx).pop();
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ Add Dialog (uses Provider instead of setState)
  void _showAddRecurringExpenseDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Recurring Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Expense Title"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                final newExpense = RecurringExpense(
                  id: DateTime.now().toString(),
                  categoryId: "general",
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  payee: titleController.text,
                  notes: "",
                  frequency: "Monthly",
                  nextDueDate: DateTime.now().add(const Duration(days: 30)),
                  isActive: true,
                );

                // 🔥 Add using Provider (instead of setState)
                Provider.of<ExpenseProvider>(context, listen: false)
                    .addRecurringExpense(newExpense);

                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
