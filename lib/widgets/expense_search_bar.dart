import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class ExpenseSearchBar extends StatelessWidget {
  const ExpenseSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.deepPurple[50],
      child: TextField(
        onChanged: (value) {
          Provider.of<ExpenseProvider>(context, listen: false)
              .updateSearchQuery(value);
        },
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          suffixIcon: Consumer<ExpenseProvider>(
            builder: (context, provider, child) {
              return provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.deepPurple),
                      onPressed: () {
                        provider.updateSearchQuery(''); FocusScope.of(context).unfocus();
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}