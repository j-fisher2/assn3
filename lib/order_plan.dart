// OrderPlan Model
class OrderPlan {
  final String date;
  final String items;
  final double totalCost;

  OrderPlan({ required this.date, required this.items, required this.totalCost});

  Map<String, dynamic> toMap() {
    return {'date': date, 'items': items, 'total_cost': totalCost};
  }
}