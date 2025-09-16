import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/category_management_screen.dart';
import '../screens/recurring_expenses_screen.dart';
import '../models/expense.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'add-expense',
          name: 'add-expense',
          builder: (context, state) {
            final expense = state.extra as Expense?;
            return AddExpenseScreen(expenseToEdit: expense);
          },
        ),
        GoRoute(
          path: 'manage-categories',
          name: 'manage-categories',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const CategoryManagementScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: 'recurring-expenses',
          name: 'recurring-expenses',
          builder: (context, state) => RecurringExpensesScreen(),
        ),
      ],
    ),
  ],
);