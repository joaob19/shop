import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final List<Product> _items = [];
  final _baseUrl = Constants.productBaseUrl;

  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  int get itemsCount => _items.length;

  Future<void> loadProducts() async {
    try {
      _items.clear();
      final response = await http.get(
        Uri.parse('$_baseUrl.json'),
      );
      if (response.body == 'null') return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      data.forEach((productId, productData) {
        _items.add(Product.fromJson(productId, productData));
      });
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> saveProduct(Map<String, Object> data) async {
    try {
      final hasId = data['id'] != null;

      final product = Product(
        id: hasId ? data['id'] as String : Random().nextDouble().toString(),
        name: data['name'] as String,
        description: data['description'] as String,
        price: double.parse(data['price'] as String),
        imageUrl: data['imageUrl'] as String,
      );

      if (hasId) {
        await updateProduct(product);
      } else {
        await addProduct(product);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$_baseUrl.json'),
      body: jsonEncode(product.toJson()),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(
      Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ),
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      await http.patch(
        Uri.parse('$_baseUrl/${product.id}.json'),
        body: jsonEncode(product.toJson()),
      );

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/${product.id}.json'),
      );

      if(response.statusCode >= 400){
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }
}
