import 'package:expense_tracker_v01/models/expense_category.dart';
import 'package:expense_tracker_v01/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/icon_picker.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 16),
            Text('Select Icon:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            IconPicker(
              selectedIcon: _selectedIcon,
              onIconSelected: (IconData icon) {
                setState(() {
                  _selectedIcon = icon;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final category = ExpenseCategory(
                    id: DateTime.now().toString(),
                    name: _nameController.text,
                    icon: _selectedIcon,
                  );
                  Provider.of<ExpenseProvider>(context, listen: false)
                      .addCategory(category);
                  Navigator.pop(context);
                }
              },
              child: Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}