import 'package:flutter/material.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = dummyProducts;

  List<Product> get items => [..._items];

  List<Product> get favoriteItems  {
    return _items.where((item) => item.isFavorite).toList();
  }

  void addProduct(Product items) {
    _items.add(items);
    notifyListeners();
  }
}