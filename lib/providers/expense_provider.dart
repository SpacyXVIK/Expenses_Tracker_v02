import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class ExpenseProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<Expense> _expenses = [];

  // List of categories
  final List<ExpenseCategory> _categories = [
    ExpenseCategory(id: '1', name: 'Food', isDefault: true, icon: Icons.restaurant),
    ExpenseCategory(id: '2', name: 'Transport', isDefault: true, icon: Icons.directions_car),
    ExpenseCategory(id: '3', name: 'Entertainment', isDefault: true, icon: Icons.movie),
    ExpenseCategory(id: '4', name: 'Office', isDefault: true, icon: Icons.work),
    ExpenseCategory(id: '5', name: 'Gym', isDefault: true, icon: Icons.fitness_center),
  ];

  // Getters
  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ExpenseProvider(this.storage) {
    _loadExpensesFromStorage();
  }

  void _loadExpensesFromStorage() async {
    // await storage.ready;
    var storedExpenses = storage.getItem('expenses');
    if (storedExpenses != null) {
      // Decode the JSON string to a List
      var decoded = jsonDecode(storedExpenses) as List;
      _expenses = List<Expense>.from(
        decoded.map((item) => Expense.fromJson(item)),
      );
      notifyListeners();
    }
  }

  // Add an expense
  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveExpensesToStorage();
    notifyListeners();
  }

  void _saveExpensesToStorage() {
    storage.setItem(
        'expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
  }

  void addOrUpdateExpense(Expense expense) {
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      // Update existing expense
      _expenses[index] = expense;
    } else {
      // Add new expense
      _expenses.add(expense);
    }
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an expense
  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a category
  void addCategory(ExpenseCategory category) {
    if (!_categories.any((cat) => cat.name == category.name)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  // Delete a category
  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _saveExpensesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Search expenses by text
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
}