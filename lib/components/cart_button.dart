import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/order_list.dart';

class CartButton extends StatefulWidget {
  final Cart cart;

  const CartButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  bool _isLoading = false;

  void _toggleLoading() {
    setState(() => _isLoading = !_isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: widget.cart.itemsCount == 0
                ? null
                : () async {
                    _toggleLoading();
                    await Provider.of<OrderList>(
                      context,
                      listen: false,
                    ).addOrder(widget.cart);

                    widget.cart.clear();
                    _toggleLoading();
                  },
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            child: const Text('COMPRAR'),
          );
  }
}
