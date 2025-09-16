import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class SpendingTrendsChart extends StatefulWidget {
  const SpendingTrendsChart({super.key});

  @override
  _SpendingTrendsChartState createState() => _SpendingTrendsChartState();
}

class _SpendingTrendsChartState extends State<SpendingTrendsChart> {
  String _selectedTimeFrame = 'Daily';
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Spending Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedTimeFrame,
                    items: _timeFrames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTimeFrame = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildLineChart(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart(ExpenseProvider provider) {
    if (provider.expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expenses recorded yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final spots = _getDataPoints(provider);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const Text('');
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    _getFormattedDate(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('Rs.${value.toInt()}',
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    switch (_selectedTimeFrame) {
      case 'Daily':
        return DateFormat('MMM d').format(date);
      case 'Weekly':
        return DateFormat('MMM d').format(date);
      case 'Monthly':
        return DateFormat('MMM').format(date);
      default:
        return '';
    }
  }

  List<FlSpot> _getDataPoints(ExpenseProvider provider) {
    final expenses = provider.expenses;
    final Map<DateTime, double> groupedExpenses = {};

    // Group expenses by date
    for (var expense in expenses) {
      DateTime key;
      switch (_selectedTimeFrame) {
        case 'Daily':
          key = DateTime(
              expense.date.year, expense.date.month, expense.date.day);
          break;
        case 'Weekly':
          // Get the start of the week
          key = expense.date.subtract(
              Duration(days: expense.date.weekday - 1));
          break;
        case 'Monthly':
          key = DateTime(expense.date.year, expense.date.month);
          break;
        default:
          key = expense.date;
      }

      groupedExpenses.update(
        key,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Convert to list and sort by date
    final sortedEntries = groupedExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Convert to FlSpot list
    return sortedEntries
        .map((entry) => FlSpot(
              entry.key.millisecondsSinceEpoch.toDouble(),
              entry.value,
            ))
        .toList();
  }
}