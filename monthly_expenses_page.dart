import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pie_chart/pie_chart.dart'; // Import pie_chart package

class MonthlyExpensesPage extends StatefulWidget {
  @override
  _MonthlyExpensesPageState createState() => _MonthlyExpensesPageState();
}

class _MonthlyExpensesPageState extends State<MonthlyExpensesPage> {
  List<Map<String, dynamic>> expenses = [];
  bool isLoading = true;

  Future<void> loadMonthlyExpenses() async {
    final url = Uri.parse("http://alsalser.atwebpages.com/get_monthly_expenses.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success']) {
        setState(() {
          expenses = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error connecting to server")));
    }
  }

  @override
  void initState() {
    super.initState();
    loadMonthlyExpenses();
  }

  // This method processes the expenses data into pie chart data
  Map<String, double> getPieChartData() {
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = expense['category'];
      double amount = double.parse(expense['total_amount'].toString());

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }

    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final pieData = getPieChartData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Expenses'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? Center(child: Text("No expenses found"))
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                dataMap: pieData, // Use the pieData for chart
                chartType: ChartType.ring, // You can use ChartType.disc as well
                colorList: [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ], // Customize the chart colors
                chartValuesOptions: ChartValuesOptions(showChartValues: true),
                ringStrokeWidth: 40,
                centerText: "Expenses",
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text('${expense['month']} - ${expense['category']}'),
                  subtitle: Text(
                    'Subcategory: ${expense['subcategory']}, Total: \$${expense['total_amount']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
