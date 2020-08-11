import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/adding_product_order.dart';

class OrderProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productList = Provider.of<AddingProductOrder>(context);
    return Column(
      children: <Widget>[
        Center(
          child: Text(
            ' Total: \$${productList.totalPrice().toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: ListView.builder(
              itemCount: productList.items.length,
              itemBuilder: (_, i) => ProductTile(
                id: productList.items[i].id,
                price: productList.items[i].price,
                quantity: productList.items[i].quantity,
                title: productList.items[i].title,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductTile extends StatelessWidget {
  final String id;
  final double price;
  final String title;
  final double quantity;

  ProductTile({
    this.id,
    this.title,
    this.price,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(
              20,
            ),
          ),
        ),
      ),
      key: Key(id),
      onDismissed: (direction) {},
      child: ListTile(
        leading: Text('${quantity.toStringAsFixed(0)}x'),
        title: Text(title),
        trailing: Text(
          price.toStringAsFixed(2),
        ),
      ),
    );
  }
}
