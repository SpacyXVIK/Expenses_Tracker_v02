import 'package:expense_tracker_v02/screens/setting_screen.dart';
import 'package:expense_tracker_v02/widgets/animated_category_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/expense_search_bar.dart';
import '../widgets/analytics_dashboard.dart';
import '../widgets/spending_trends_chart.dart';
import '../widgets/monthly_budget_widget.dart'; // Import the new widget
import '../providers/theme_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed to 4 tabs

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
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
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.deepPurple[800],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellow,
          labelColor: Colors.white,
          isScrollable: true, // Add this to prevent tab overflow
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'By Date'),
            Tab(icon: Icon(Icons.category), text: 'By Category'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'), // New tab
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white,),
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
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              if (value == 'export') {
                try {
                  final filePath = await provider.exportToExcel();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to: $filePath')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              } else if (value == 'import') {
                try {
                  await provider.importFromExcel();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import successful')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e')),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Export to Excel'),
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Import from Excel'),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    context.pushNamed('manage-categories');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Recurring Expenses'),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed('recurring-expenses');
                  },
                ),
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: Text(
                    themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  onTap: () {
                    themeProvider.toggleTheme();
                  },
                ),ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
              ],
            );
          },
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
        onPressed: () => context.pushNamed('add-expense'),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _updateFilterDates(String filter) {
    setState(() {
      switch (filter) {
        case 'Today':
          _startDate = DateTime.now().subtract(const Duration(hours: 24));
          _endDate = DateTime.now();
          break;
        case 'This Week':
          _startDate = DateTime.now().subtract(const Duration(days: 7));
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
            colorScheme: const ColorScheme.light(
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

        return Column(
          children: [
            MonthlyBudgetWidget(), // Add this at the top
            Expanded(
              child: ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  String formattedDateTime = 
                      DateFormat('MMM dd, yyyy - hh:mm a').format(expense.date);
                  
                  return Dismissible(
                    key: Key(expense.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      // Change removeExpense to deleteExpense
                      provider.deleteExpense(expense.id);
                    },
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.pushNamed(
                          'add-expense',
                          extra: expense,
                        );
                      },
                      child: Card(
                        color: Colors.greenAccent,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                expense.payee,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),

                              Text(
                                " - Rs.${expense.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildExpensesByCategory(BuildContext context) {
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

        var selectedCategory = _selectedCategoryId != null 
            ? provider.categories.firstWhere(
                (cat) => cat.id == _selectedCategoryId,
                orElse: () => provider.categories.first)
            : null;

        // Filter expenses by selected category
        if (_selectedCategoryId != null) {
          filteredExpenses = filteredExpenses
              .where((expense) => expense.categoryId == _selectedCategoryId)
              .toList();
        }

        return Column(
          children: [
            AnimatedCategorySelector(
              categories: provider.categories,
              selectedCategory: selectedCategory,
              onSelect: (category) {
                setState(() {
                  _selectedCategoryId = 
                      _selectedCategoryId == category.id ? null : category.id;
                });
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: ListView.builder(
                  key: ValueKey(_selectedCategoryId),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    String formattedDateTime = 
                        DateFormat('MMM dd, yyyy - hh:mm a').format(expense.date);

                    return AnimatedScale(
                      duration: Duration(milliseconds: 300),
                      scale: 1.0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: 1.0,
                        child: ListTile(
                          title: Text(
                            "${expense.payee} - \$${expense.amount.toStringAsFixed(2)}",
                          ),
                          subtitle: Text(formattedDateTime),
                          leading: Icon(
                            getCategoryIconById(context, expense.categoryId),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
