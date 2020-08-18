import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/adding_product_order.dart';

class OrderProductList extends StatefulWidget {
  @override
  _OrderProductListState createState() => _OrderProductListState();
}

class _OrderProductListState extends State<OrderProductList> {
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
                id: productList.items.values.toList()[i].id,
                price: productList.items.values.toList()[i].price,
                quantity: productList.items.values.toList()[i].quantity,
                title: productList.items.values.toList()[i].title,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductTile extends StatefulWidget {
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
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  @override
  Widget build(BuildContext context) {
    var addProdProvider = Provider.of<AddingProductOrder>(context);

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
      key: Key(widget.id),
      onDismissed: (direction) {
        setState(() {
          addProdProvider.removeProduct(widget.id);
        });
      },
      child: ListTile(
        title: Text(widget.title),
        leading: Text('Qty:${widget.quantity.toStringAsFixed(0)}'),
        trailing: Text(
          widget.price.toStringAsFixed(2),
        ),
      ),
    );
  }
}
