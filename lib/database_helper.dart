import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_ordering.db');
    print(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY,
        name TEXT,
        cost REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        items TEXT,
        total_cost REAL
      )
    ''');
    await insertFoodItems(db); // Insert sample data when creating the database
  }

  Future<void> insertFoodItems(Database db) async {
    final foodItems = [
      {'name': 'Pizza', 'cost': 8.99},
      {'name': 'Burger', 'cost': 5.99},
      {'name': 'Sushi', 'cost': 12.50},
      {'name': 'Pasta', 'cost': 7.75},
      {'name': 'Salad', 'cost': 4.50},
      {'name': 'Sandwich', 'cost': 6.20},
      {'name': 'Taco', 'cost': 3.99},
      {'name': 'Steak', 'cost': 15.00},
      {'name': 'Ice Cream', 'cost': 2.50},
      {'name': 'Coffee', 'cost': 1.75},
      {'name': 'Tea', 'cost': 1.50},
      {'name': 'Smoothie', 'cost': 4.00},
      {'name': 'Fries', 'cost': 2.99},
      {'name': 'Soup', 'cost': 3.25},
      {'name': 'Chicken', 'cost': 9.50},
      {'name': 'Fish', 'cost': 11.00},
      {'name': 'Chips', 'cost': 1.50},
      {'name': 'Juice', 'cost': 2.00},
      {'name': 'Donut', 'cost': 1.00},
      {'name': 'Muffin', 'cost': 1.75},
    ];

    for (var item in foodItems) {
      print(item);
      await db.insert('food_items', item);
    }
    print("inserted");
  }
}