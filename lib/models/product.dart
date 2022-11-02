import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  static Product fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      imageUrl: json['imageUrl'] as String,
      isFavorite: json['isFavorite'] as bool,
    );
  }

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    try {
      _toggleFavorite();

      final response = await http.patch(
        Uri.parse(
          '${Constants.productBaseUrl}/$id.json',
        ),
        body: jsonEncode({'isFavorite': isFavorite}),
      );

      if (response.statusCode >= 400) {
        _toggleFavorite();

        throw HttpException(
          msg: 'Não foi possível alterar a marcação de favorito desse item.',
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      _toggleFavorite();
    }
  }
}
