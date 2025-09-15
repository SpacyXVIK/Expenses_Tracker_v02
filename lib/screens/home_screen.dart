import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../screens/add_expense_screen.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/expense.dart';
import '../widgets/expense_search_bar.dart';
import '../widgets/analytics_dashboard.dart';
import '../widgets/spending_trends_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  // Filter options
  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'Custom'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed to 4 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: Colors.deepPurple[800],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          labelColor: Colors.white,
          isScrollable: true, // Add this to prevent tab overflow
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'By Date'),
            Tab(icon: Icon(Icons.category), text: 'By Category'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'), // New tab
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String value) async {
              setState(() => _selectedFilter = value);
              if (value == 'Custom') {
                await _showDateRangePicker(context);
              } else {
                _updateFilterDates(value);
              }
            },
            itemBuilder: (BuildContext context) {
              return _filterOptions.map((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option == _selectedFilter
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Colors.deepPurple,
                      ),
                      SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.category, color: Colors.deepPurple),
              title: Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context); // This closes the drawer
                Navigator.pushNamed(context, '/manage_categories');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          ExpenseSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildExpensesByDate(context),
                buildExpensesByCategory(context),
                AnalyticsDashboard(),
                SpendingTrendsChart(), // New tab view
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddExpenseScreen()),
        ),
        tooltip: 'Add Expense',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _updateFilterDates(String filter) {
    setState(() {
      switch (filter) {
        case 'Today':
          _startDate = DateTime.now().subtract(Duration(hours: 24));
          _endDate = DateTime.now();
          break;
        case 'This Week':
          _startDate = DateTime.now().subtract(Duration(days: 7));
          _endDate = DateTime.now();
          break;
        case 'All':
          _startDate = null;
          _endDate = null;
          break;
        default:
          // Custom dates are handled by date picker
          break;
      }
    });
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.deepPurple,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget buildExpensesByDate(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        var filteredExpenses = provider.getFilteredExpenses();
        
        if (filteredExpenses.isEmpty) {
          return Center(
            child: Text(
              provider.searchQuery.isEmpty
                  ? "Click the + button to record expenses."
                  : "No expenses found matching '${provider.searchQuery}'",
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredExpenses.length,
          itemBuilder: (context, index) {
            final expense = filteredExpenses[index];
            String formattedDateTime = 
                DateFormat('MMM dd, yyyy - hh:mm a').format(expense.date);
            
            return Dismissible(
              key: Key(expense.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                provider.removeExpense(expense.id);
              },
              background: Container(
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(
                        expenseToEdit: expense,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.greenAccent,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${expense.payee}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),

                        Text(
                          " - Rs.${expense.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDateTime,
                        ), // Updated to show date and time
                        Text(
                          "- Category: ${getCategoryNameById(context, expense.categoryId)}",
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildExpensesByCategory(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Use filtered expenses instead of all expenses
        var filteredExpenses = provider.getFilteredExpenses();
        
        if (filteredExpenses.isEmpty) {
          return Center(
            child: Text(
              provider.searchQuery.isEmpty
                  ? "Click the + button to record expenses."
                  : "No expenses found matching '${provider.searchQuery}'",
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          );
        }

        // Grouping expenses by category
        var grouped = groupBy(filteredExpenses, (Expense e) => e.categoryId);
        return ListView(
          children: grouped.entries.map((entry) {
            String categoryName = getCategoryNameById(
              context,
              entry.key,
            ); // Ensure you implement this function
            double total = entry.value.fold(
              0.0,
              (double prev, Expense element) => prev + element.amount,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        getCategoryIconById(context, entry.key),
                        color: Colors.deepPurple,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "$categoryName - Total: \$${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // to disable scrolling within the inner list view
                  shrinkWrap:
                      true, // necessary to integrate a ListView within another ListView
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    Expense expense = entry.value[index];
                    // Update date format to include time
                    String formattedDateTime = DateFormat(
                      'MMM dd, yyyy - hh:mm a',
                    ).format(expense.date);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddExpenseScreen(expenseToEdit: expense),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.monetization_on,
                          color: Colors.deepPurple,
                        ),
                        title: Text(
                          "${expense.payee} - \$${expense.amount.toStringAsFixed(2)}",
                        ),
                        subtitle: Text(
                          formattedDateTime,
                        ), // Updated to show date and time
                      ),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // home_screen.dart
  String getCategoryNameById(BuildContext context, String categoryId) {
    var category = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).categories.firstWhere((cat) => cat.id == categoryId);
    return category.name;
  }

  IconData getCategoryIconById(BuildContext context, String categoryId) {
    var category = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).categories.firstWhere((cat) => cat.id == categoryId);
    return category.icon;
  }
}
