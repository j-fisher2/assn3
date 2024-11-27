class FoodItem {
  final int id;
  final String name;
  final double cost;

  FoodItem({required this.id, required this.name, required this.cost});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.cost == cost;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ cost.hashCode;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'cost': cost};
  }
}