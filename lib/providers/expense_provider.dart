import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/recurring_expense.dart';
import '../services/excel_service.dart';

class ExpenseProvider with ChangeNotifier {
  late Box<Expense> _expenseBox;
  late Box<ExpenseCategory> _categoryBox;
  late Box<double> _settingsBox;
  late Box<RecurringExpense> _recurringExpenseBox;

  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  List<RecurringExpense> _recurringExpenses = [];
  String _searchQuery = '';
  double _monthlyBudget = 0.0;

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  String get searchQuery => _searchQuery;
  double get monthlyBudget => _monthlyBudget;
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;

  final _excelService = ExcelService();

  ExpenseProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    _expenseBox = await Hive.openBox<Expense>('expenses');
    _categoryBox = await Hive.openBox<ExpenseCategory>('categories');
    _settingsBox = await Hive.openBox<double>('settings');
    _recurringExpenseBox = await Hive.openBox<RecurringExpense>('recurring_expenses');

    await _loadExpenses();
    await _loadCategories();
    await loadMonthlyBudget();
    await _loadRecurringExpenses();
    _checkAndAddRecurringExpenses();
  }

  Future<void> _loadExpenses() async {
    _expenses = _expenseBox.values.toList();
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    if (_categoryBox.isEmpty) {
      // Add default categories
      await _categoryBox.addAll([
        ExpenseCategory(id: '1', name: 'Food', isDefault: true, icon: Icons.restaurant),
        ExpenseCategory(id: '2', name: 'Transport', isDefault: true, icon: Icons.directions_car),
        ExpenseCategory(id: '3', name: 'Entertainment', isDefault: true, icon: Icons.movie),
        ExpenseCategory(id: '4', name: 'Office', isDefault: true, icon: Icons.work),
        ExpenseCategory(id: '5', name: 'Gym', isDefault: true, icon: Icons.fitness_center),
      ]);
    }
    _categories = _categoryBox.values.toList();
    notifyListeners();
  }

  Future<void> _loadRecurringExpenses() async {
    _recurringExpenses = _recurringExpenseBox.values.toList();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
    await _loadExpenses();
  }

  Future<void> addOrUpdateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
    await _loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
    await _loadExpenses();
  }

  Future<void> addCategory(ExpenseCategory category) async {
    if (!_categories.any((cat) => cat.name == category.name)) {
      await _categoryBox.put(category.id, category);
      await _loadCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    await _loadCategories();
  }

  Future<void> addRecurringExpense(RecurringExpense recurringExpense) async {
    await _recurringExpenseBox.put(recurringExpense.id, recurringExpense);
    await _loadRecurringExpenses();
  }

  /// ✅ New update function for recurring expenses
  Future<void> updateRecurringExpense(RecurringExpense recurringExpense) async {
    await _recurringExpenseBox.put(recurringExpense.id, recurringExpense);
    await _loadRecurringExpenses();
  }

  Future<void> deleteRecurringExpense(String id) async {
    await _recurringExpenseBox.delete(id);
    await _loadRecurringExpenses();
  }

  List<Expense> getFilteredExpenses() {
    if (_searchQuery.isEmpty) {
      return _expenses;
    }

    final query = _searchQuery.toLowerCase();
    return _expenses.where((expense) {
      return expense.payee.toLowerCase().contains(query) ||
             (expense.notes?.toLowerCase().contains(query) ?? false) ||
             getCategoryById(expense.categoryId).name.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  ExpenseCategory getCategoryById(String id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => _categories.first,
    );
  }

  Future<void> loadMonthlyBudget() async {
    _monthlyBudget = _settingsBox.get('monthlyBudget', defaultValue: 0.0)!;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double amount) async {
    await _settingsBox.put('monthlyBudget', amount);
    _monthlyBudget = amount;
    notifyListeners();
  }

  double getMonthlyExpenseTotal() {
    final now = DateTime.now();
    return _expenses
        .where((expense) => 
            expense.date.month == now.month && 
            expense.date.year == now.year)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<String> exportToExcel() async {
    return await _excelService.exportExpenses(_expenses);
  }

  Future<void> importFromExcel() async {
    final expensesData = await _excelService.importExpenses();
    for (var data in expensesData) {
      final expense = Expense(
        id: data['id'],
        categoryId: data['categoryId'],
        amount: data['amount'],
        date: data['date'],
        payee: data['payee'],
        notes: data['notes'],
      );
      await addExpense(expense);
    }
  }

  Future<void> _checkAndAddRecurringExpenses() async {
    final now = DateTime.now();
    for (var recurring in _recurringExpenses) {
      if (!recurring.isActive) continue;
      
      if (recurring.nextDueDate.isBefore(now)) {
        // Add the expense
        final expense = Expense(
          id: DateTime.now().toString(),
          categoryId: recurring.categoryId,
          amount: recurring.amount,
          date: recurring.nextDueDate,
          payee: recurring.payee,
          notes: '(Recurring) ${recurring.notes ?? ''}',
        );
        await addExpense(expense);

        // Calculate next due date
        DateTime nextDueDate;
        switch (recurring.frequency) {
          case 'monthly':
            nextDueDate = DateTime(
              recurring.nextDueDate.year,
              recurring.nextDueDate.month + 1,
              recurring.nextDueDate.day,
            );
            break;
          case 'weekly':
            nextDueDate = recurring.nextDueDate.add(Duration(days: 7));
            break;
          case 'yearly':
            nextDueDate = DateTime(
              recurring.nextDueDate.year + 1,
              recurring.nextDueDate.month,
              recurring.nextDueDate.day,
            );
            break;
          default:
            continue;
        }

        // Update recurring expense with new due date
        final updatedRecurring = RecurringExpense(
          id: recurring.id,
          categoryId: recurring.categoryId,
          amount: recurring.amount,
          payee: recurring.payee,
          notes: recurring.notes,
          frequency: recurring.frequency,
          nextDueDate: nextDueDate,
          isActive: recurring.isActive,
        );
        await addRecurringExpense(updatedRecurring);
      }
    }
  }
}