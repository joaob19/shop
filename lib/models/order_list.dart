import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';

class OrderList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Order> _items;

  OrderList(
    this._token,
    this._userId,
    this._items,
  );

  List<Order> get items => [..._items];

  final _baseUrl = Constants.orderBaseUrl;

  int get itemsCount => _items.length;

  Future<void> loadOrders() async {
    try {
      List<Order> items = [];
      final response = await http.get(
        Uri.parse('$_baseUrl/$_userId.json?auth=$_token'),
      );
      if (response.body == 'null') return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      data.forEach((orderId, orderData) {
        items.add(
          Order.fromJson(
            orderId,
            orderData,
          ),
        );
      });

      _items = items.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('$_baseUrl/$_userId.json?auth=$_token'),
      body: jsonEncode({
        'total': cart.totalAmount,
        'date': date.toIso8601String(),
        'products': cart.items.values.map((cartItem) {
          return cartItem.toJson();
        }).toList(),
      }),
    );

    final id = jsonDecode(response.body)['name'];
    _items.insert(
      0,
      Order(
        id: id,
        date: date,
        total: cart.totalAmount,
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }
}
