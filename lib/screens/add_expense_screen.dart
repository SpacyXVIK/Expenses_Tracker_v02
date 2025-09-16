import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/add_category_dialog.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({Key? key, this.expenseToEdit}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _payeeController;
  late TextEditingController _noteController;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.expenseToEdit?.amount.toString() ?? '');
    _payeeController =
        TextEditingController(text: widget.expenseToEdit?.payee ?? '');
    _noteController =
        TextEditingController(text: widget.expenseToEdit?.notes ?? '');
    _selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
    _selectedCategoryId = widget.expenseToEdit?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.expenseToEdit == null ? 'Add Expense' : 'Edit Expense'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField(_amountController, 'Amount',
                const TextInputType.numberWithOptions(decimal: true)),
            buildTextField(_payeeController, 'Payee', TextInputType.text),
            buildTextField(_noteController, 'note', TextInputType.text),
            buildDateField(_selectedDate),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Adjust the padding as needed
              child: buildCategoryDropdown(expenseProvider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _saveExpense,
          child: const Text('Save Expense'),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields!')));
      return;
    }

    final expense = Expense(
      id: widget.expenseToEdit?.id ??
          DateTime.now().toString(), // Assuming you generate IDs like this
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      payee: _payeeController.text,
      notes: _noteController.text,
      date: _selectedDate,
    );

    // Calling the provider to add or update the expense
    Provider.of<ExpenseProvider>(context, listen: false)
        .addOrUpdateExpense(expense);
    Navigator.pop(context);
  }

  // Helper method to build a text field
  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: type,
      ),
    );
  }

// Helper method to build the date picker field
  Widget buildDateField(DateTime selectedDate) {
    return ListTile(
      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

// Helper method to build the category dropdown
  Widget buildCategoryDropdown(ExpenseProvider provider) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddCategoryDialog(onAdd: (newCategory) {
              setState(() {
                _selectedCategoryId =
                    newCategory.id; // Automatically select the new category
                provider.addCategory(
                    newCategory); // Add to provider, assuming this method exists
              });
            }),
          );
        } else {
          setState(() => _selectedCategoryId = newValue);
        }
      },
      items: provider.categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList()
        ..add(const DropdownMenuItem(
          value: "New",
          child: Text("Add New Category"),
        )),
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
    );
  }
}