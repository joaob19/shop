import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderList>(context, listen: false);
    final items = orders.items;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Meus pedidos'),
      ),
      body: FutureBuilder(
        future: orders.loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.error != null) {
            return const Center(
              child: Text('Ocorreu um erro.'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: orders.loadOrders,
              child: Consumer<OrderList>(
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final order = items[index];
                      return OrderWidget(order: order);
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
