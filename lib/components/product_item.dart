import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem(
    this.product, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          product.imageUrl,
        ),
      ),
      title: Text(product.name),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.productForm,
                  arguments: product,
                );
              },
              color: Theme.of(context).primaryColor,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Excluir produto'),
                      content: const Text('Tem certeza?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Não'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<ProductList>(
                              context,
                              listen: false,
                            ).removeProduct(product);

                            Navigator.of(context).pop();
                          },
                          child: const Text('Sim'),
                        ),
                      ],
                    );
                  },
                );
              },
              color: Theme.of(context).errorColor,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
