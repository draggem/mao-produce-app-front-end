import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/order_product_model.dart';

class OrderTileCustomer extends StatefulWidget {
  final String id;
  final double totalprice;
  final DateTime dateTime;
  final bool isOpen;
  final List<OrderProductModel> products;

  OrderTileCustomer({
    this.id,
    this.totalprice,
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
        height: _expanded ? min(widget.products.length * 20.0 + 110, 200) : 95,
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: widget.isOpen == true
                    ? Icon(Icons.check_circle, color: Colors.pink)
                    : Icon(Icons.remove_circle, color: Colors.black),
                title: Text(widget.id),
                subtitle: Text(
                  DateFormat.yMMMMEEEEd().format(widget.dateTime).toString(),
                ),
                trailing: Column(
                  children: <Widget>[
                    Text(
                      widget.totalprice.toStringAsFixed(2),
                    ),
                    SizedBox(height: 5),
                    IconButton(
                        icon: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        })
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
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x \$${prod.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
    );
  }
}
