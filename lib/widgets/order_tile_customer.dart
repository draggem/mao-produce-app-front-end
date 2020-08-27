import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/order_product_model.dart';

class OrderTileCustomer extends StatefulWidget {
  final String id;
  final double totalPrice;
  final DateTime dateTime;
  final bool isOpen;
  final List<dynamic> products;

  OrderTileCustomer({
    this.id,
    this.totalPrice,
    this.dateTime,
    this.isOpen,
    this.products,
  });

  @override
  _OrderTileCustomerState createState() => _OrderTileCustomerState();
}

class _OrderTileCustomerState extends State<OrderTileCustomer> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _expanded ? min(widget.products.length * 20.0 + 110, 200) : 100,
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: widget.isOpen == false
                    ? Icon(Icons.check_circle, color: Colors.pink, size: 50)
                    : Icon(Icons.adjust, color: Colors.black, size: 50),
                title: Text(widget.id, maxLines: 1),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(widget.dateTime).toString(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RichText(
                      overflow: TextOverflow.fade,
                      text: TextSpan(
                          text: '\$${widget.totalPrice.toStringAsFixed(2)}'),
                    ),
                    IconButton(
                      icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _expanded
                    ? min(widget.products.length * 20.0 + 10, 100)
                    : 0,
                child: ListView(
                  children: widget.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.fade,
                                strutStyle: StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                  text: prod.title,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.fade,
                                strutStyle: StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                  text:
                                      '${prod.quantity.toStringAsFixed(0)}x   \$${prod.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          foregroundColor: Colors.white,
          caption: 'Edit',
          color: Colors.orange,
          icon: Icons.edit,
          onTap: () {},
        ),
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {}),
      ],
    );
  }
}
