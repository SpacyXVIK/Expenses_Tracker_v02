import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_category.dart';

class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // Calculate total expenses by category
          Map<String, double> categoryTotals = {};
          for (var expense in provider.expenses) {
            categoryTotals.update(
              expense.categoryId,
              (value) => value + expense.amount,
              ifAbsent: () => expense.amount,
            );
          }

          // Generate pie chart sections
          List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
            ExpenseCategory category = provider.getCategoryById(entry.key);
            final double percentage = 
                (entry.value / provider.expenses.fold(0.0, (sum, expense) => sum + expense.amount)) * 100;
            
            return PieChartSectionData(
              color: Colors.primaries[provider.categories.indexOf(category) % Colors.primaries.length],
              value: entry.value,
              title: '${category.name}\n${percentage.toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

          return Container(
            height: 400,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Expense Distribution by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: sections.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses recorded yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Center(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}