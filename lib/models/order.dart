import 'package:shop/models/cart_item.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    required this.id,
    required this.total,
    required this.products,
    required this.date,
  });

  static Order fromJson(String id, Map<String,dynamic> json) {
    return Order(
      id: id,
      total: json['total'] as double,
      products: (json['products'] as List<dynamic>).map((cartItemData) {
        return CartItem.fromJson(cartItemData);
      }).toList(),
      date: DateTime.parse(json['date'].toString()),
    );
  }
}
