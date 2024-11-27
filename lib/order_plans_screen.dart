import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/database_helper.dart';
import 'package:food_ordering_app/FoodItem.dart';
import 'order_plan.dart';
import 'food_ordering_screen.dart';
import 'query_order_plans.dart';

class OrderPlansScreen extends StatefulWidget {
  @override
  _OrderPlansScreenState createState() => _OrderPlansScreenState();
}

class _OrderPlansScreenState extends State<OrderPlansScreen> {
  late Future<List<OrderPlan>> _orderPlansFuture;

  @override
  void initState() {
    super.initState();
    _orderPlansFuture = _getOrderPlans();
  }

  Future<List<OrderPlan>> _getOrderPlans() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('order_plans');

    return List.generate(maps.length, (i) {
      return OrderPlan(
        date: maps[i]['date'] as String,
        items: maps[i]['items'] as String,
        totalCost: (maps[i]['total_cost'] as num).toDouble(),
      );
    });
  }

  _deleteOrder(String date, String items, double totalCost) async {
    final db = await DatabaseHelper().database;
    try {
      final result = await db.rawDelete(
        'DELETE FROM order_plans WHERE date = ? AND items = ? AND total_cost = ?',
        [date, items, totalCost], // Arguments to match in the query
      );

      if (result > 0) {
        print('Order deleted successfully');
        setState(() {
          _orderPlansFuture = _getOrderPlans(); // Refresh the order plans list
        });
      } else {
        print('No matching order found to delete');
      }
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plans'),
      ),
      body: _buildOrderPlansList(),
    );
  }

  Widget _buildOrderPlansList() {
    return FutureBuilder<List<OrderPlan>>(
      future: _orderPlansFuture,
      builder: (BuildContext context, AsyncSnapshot<List<OrderPlan>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error fetching order plans: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No order plans available.'));
        } else {
          final orderPlans = snapshot.data!;
          return ListView.builder(
            itemCount: orderPlans.length,
            itemBuilder: (context, index) {
              final plan = orderPlans[index];
              return Card(
                  child: ListTile(
                    title: Text('Date: ${plan.date}'),
                    subtitle: Text(
                        'Items: ${plan.items}\nTotal Cost: \$${plan.totalCost
                            .toStringAsFixed(2)}'),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _editOrder(
                                    plan.date, plan.items, plan.totalCost,
                                    context),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              _deleteOrder(
                                  plan.date, plan.items, plan.totalCost);
                            },
                          ),
                        ]

                    ),
                  )
              );
            },
          );
        }
      },
    );
  }

  _editOrder(String date, String items, double totalCost,
      BuildContext context) async {
    // Text controllers for user input
    TextEditingController dateController = TextEditingController(text: date);

    // Show a dialog for the user to edit the order
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Order Plan Date'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                    false); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Retrieve the new values from the text controllers
                String newDate = dateController.text;

                // Update the order in the database
                await _updateOrder(date, items, totalCost, newDate);
                Navigator.of(context).pop(
                    true); // Close the dialog and update the list
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    // Refresh the list if the order was updated
    if (result == true) {
      setState(() {
        _orderPlansFuture = _getOrderPlans(); // Reload the updated list
      });
    }
  }

  _updateOrder(String date, String items, double totalCost,
      String newDate) async {
    final db = await DatabaseHelper().database;
    try {
      // Update the order in the database with the new values
      final result = await db.rawUpdate(
        'UPDATE order_plans SET date = ? WHERE date = ? AND items = ? AND total_cost = ?',
        [newDate, date, items, totalCost],
      );

      if (result > 0) {
        print('Order updated successfully');
      } else {
        print('No matching order found to update');
      }
    } catch (e) {
      print('Error updating order: $e');
    }
  }
}