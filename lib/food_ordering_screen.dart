import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/database_helper.dart';
import 'package:food_ordering_app/FoodItem.dart';
import 'order_plan.dart';
import 'query_order_plans.dart';
import 'order_plans_screen.dart';

class FoodOrderingScreen extends StatefulWidget {
  @override
  _FoodOrderingScreenState createState() => _FoodOrderingScreenState();
}

class _FoodOrderingScreenState extends State<FoodOrderingScreen> {
  final _targetCostController = TextEditingController();
  final _dateController = TextEditingController();
  final _selectedItems = <FoodItem>[];
  double _totalCost = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Food Ordering App')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin:EdgeInsets.all(16.0),
                child:

                TextField(
                  controller: _targetCostController,
                  decoration: InputDecoration(
                    labelText: 'Target Cost per Day',
                    labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<FoodItem>>(
                  future: _getFoodItems(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return Card(
                            elevation: 4.0, // Adds shadow for a better appearance
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Spacing around cards
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // Rounded corners
                            ),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                              trailing: Checkbox(
                                value: _selectedItems.contains(item),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      double? budget = double.tryParse(_targetCostController.text);
                                      print(budget);
                                      if (budget != null && _totalCost + item.cost > budget) {
                                        _showAlertDialog(context);
                                      } else {
                                        _selectedItems.add(item);
                                        _totalCost += item.cost;
                                      }
                                    } else {
                                      _selectedItems.remove(item);
                                      _totalCost -= item.cost;
                                    }
                                  });
                                },
                              ),
                            )
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                  children:[
                    Expanded(
                      child: ElevatedButton(
                        style:ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _saveOrderPlan(context),
                        child: Text('Save Order Plan'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style:ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OrderPlansScreen()),
                          );
                        },
                        child: Text('View Order Plans'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () {
                          _queryOrderPlan(context); // Calls the function when the button is pressed
                        },
                        child: Text('Query Order Plan'),
                      ),
                    ),
                  ]
              )
            ],
          ),
        )
    );
  }

  // Function to display the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date is today
      firstDate: DateTime(2000), // The earliest allowed date
      lastDate: DateTime(2101), // The latest allowed date
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // Format the date
      });
    }
  }
  void _queryOrderPlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QueryOrderPlanScreen()),
    );
  }


  // Function to show the alert dialog when budget exceeds
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Alert'),
          content: Text('The total cost exceeds your budget.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Fetch the food items from the database
  Future<List<FoodItem>> _getFoodItems() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('food_items');

    return List.generate(maps.length, (i) {
      return FoodItem(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        cost: (maps[i]['cost'] as num).toDouble(),
      );
    });
  }

  // Function to save the order plan
  void _saveOrderPlan(BuildContext context) async {
    final db = await DatabaseHelper().database;
    final date = _dateController.text;
    final items = _selectedItems.map((item) => item.name).join(', ');
    final orderPlan = OrderPlan(
      date: date,
      items: items,
      totalCost: _totalCost,
    );

    await db.insert('order_plans', {
      'date': orderPlan.date,
      'items': orderPlan.items,
      'total_cost': orderPlan.totalCost,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Plan Saved!')));
  }

}