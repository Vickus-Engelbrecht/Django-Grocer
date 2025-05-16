class GroceryItem {
  final String name;
  final int quantity;
  final double? price; // optional
  final String? preferredStore;

  GroceryItem({
    required this.name,
    required this.quantity,
    this.price,
    this.preferredStore,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
  };

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity, 'price': price};
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      name: map['name'],
      quantity: map['quantity'],
      price: (map['price'] as num?)?.toDouble(),
    );
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
    name: json['name'],
    quantity: json['quantity'],
    price: (json['price'] as num?)?.toDouble(),
  );
}
