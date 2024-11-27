import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/database_helper.dart';
import 'package:food_ordering_app/FoodItem.dart';
import 'order_plan.dart';
import 'food_ordering_screen.dart';
import 'order_plans_screen.dart';

class QueryOrderPlanScreen extends StatelessWidget {
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Query Order Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter Date',
                labelStyle: TextStyle(fontSize: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Get the date entered by the user
                String date = _dateController.text;

                // Make sure the date is not empty before querying
                if (date.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a date to search for.')),
                  );
                  return;
                }

                // Show a SnackBar indicating that the query is being executed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Querying Order Plan for $date')),
                );

                // Access the database and perform the query using the LIKE keyword
                final db = await DatabaseHelper().database;

                try {
                  final result = await db.query(
                    'order_plans', // Table name
                    where: 'date LIKE ?', // The condition for the LIKE query
                    whereArgs: ['%$date%'], // Using % to match any records containing the entered date
                  );

                  // Check if there are results
                  if (result.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No order plans found for $date.')),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Order Plans for $date'),
                        content: Container(
                          width: double.maxFinite,
                          height: 400, // Adjust height as needed
                          child: ListView.builder(
                            itemCount: result.length, // Use the result length
                            itemBuilder: (context, index) {
                              final plan = result[index]; // Each plan from the result
                              return Card(
                                elevation: 4.0,
                                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  title: Text('Date: ${plan['date']}'), // Display the date
                                  subtitle: Text('Items: ${plan['items']}\nTotal Cost: \$${(double.tryParse(plan['total_cost'].toString()) ?? 0.0).toStringAsFixed(2)}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // Handle any errors that occur during the query
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error querying the database: $e')),
                  );
                }
              },

              child: Text('Query'),
            ),
          ],
        ),
      ),
    );
  }
}
