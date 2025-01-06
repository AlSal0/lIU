import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'expens_page.dart';
import 'monthly_expenses_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> calculations = [];
  final TextEditingController calculationNameController = TextEditingController();

  // Load calculations from the server
  Future<void> loadCalculations() async {
    final url = Uri.parse("http://alsalser.atwebpages.com/get_calculations.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          calculations = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error connecting to server")));
    }
  }

  // Add a new calculation to the server
  Future<void> addCalculation(String name) async {
    final url = Uri.parse("http://alsalser.atwebpages.com/add_calculation.php");
    final response = await http.post(url, body: {'name': name});

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Calculation added successfully!")));
        loadCalculations();
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
    loadCalculations();  // Load calculations when the page is initialized
  }

  // Show dialog to add a new calculation
  void showAddCalculationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Calculation"),
        content: TextField(
          controller: calculationNameController,
          decoration: InputDecoration(labelText: "Calculation Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // Close dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final name = calculationNameController.text.trim();
              if (name.isNotEmpty) {
                addCalculation(name);  // Add the new calculation
                Navigator.of(context).pop();  // Close dialog
              }
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
      appBar: AppBar(
        title: Text("Expense Tracker"),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),  // Icon for monthly expenses
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonthlyExpensesPage(),  // Navigate to monthly expenses page
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: calculations.length,
        itemBuilder: (context, index) {
          final calculation = calculations[index];
          return ListTile(
            title: Text(calculation['name']),
            subtitle: Text("Created on: ${calculation['created_at']}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpensePage(
                    calculationId: calculation['id'],  // Passing the calculation ID
                    calculationName: calculation['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCalculationDialog,  // Show dialog to add a new calculation
        child: Icon(Icons.add),
      ),
    );
  }
}
