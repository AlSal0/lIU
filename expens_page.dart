import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpensePage extends StatefulWidget {
  final int calculationId;
  final String calculationName;

  const ExpensePage({required this.calculationId, required this.calculationName});

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<Map<String, dynamic>> expenses = [];
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Food';
  String selectedSubcategory = 'Supermarket';

  Map<String, List<String>> subcategories = {
    'Food': ['Supermarket', 'Restaurants'],
    'Car': ['Gas', 'Maintenance', 'Insurance', 'Payments'],
    'Household': ['Electricity', 'Ishterak', 'Gas', 'Water', 'Supplies'],
    'Leisure': ['Trips', 'Holidays'],
    'Health': ['Insurance', 'Doctors', 'Dental'],
  };

  Future<void> loadExpenses() async {
    final url = Uri.parse("http://alsalser.atwebpages.com/get_expenses.php?calculation_id=${widget.calculationId}");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          expenses = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error connecting to server")));
    }
  }

  Future<void> addExpense(double amount, String category, String subcategory) async {
    final url = Uri.parse("http://alsalser.atwebpages.com/add_expense.php");
    final response = await http.post(url, body: {
      'calculation_id': widget.calculationId.toString(),
      'amount': amount.toString(),
      'category': category,
      'subcategory': subcategory,
      'date': DateTime.now().toIso8601String(),
    });

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Expense added successfully!")));
        loadExpenses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error connecting to server")));
    }
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              items: subcategories.keys.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  selectedSubcategory = subcategories[selectedCategory]!.first;
                });
              },
            ),
            DropdownButton<String>(
              value: selectedSubcategory,
              items: subcategories[selectedCategory]!.map((subcategory) {
                return DropdownMenuItem(value: subcategory, child: Text(subcategory));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubcategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a valid amount!")),
                );
                return;
              }
              addExpense(amount, selectedCategory, selectedSubcategory);
              amountController.clear();
              Navigator.of(context).pop();
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.calculationName)),
      body: expenses.isEmpty
          ? Center(child: Text("No expenses yet. Start by adding one!"))
          : ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text('${expense['category']} - ${expense['subcategory']}'),
            subtitle: Text('Amount: \$${expense['amount']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddExpenseDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
