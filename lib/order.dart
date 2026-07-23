class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: json['Item'] ?? '',
      itemName: json['ItemName'] ?? '',
      price: (json['Price'] as num).toDouble(),
      currency: json['Currency'] ?? 'USD',
      quantity: json['Quantity'] as int,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }
}
