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
  final List<dynamic> products;

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
                    ? Icon(Icons.check_circle, color: Colors.pink, size: 50)
                    : Icon(Icons.remove_circle, color: Colors.black, size: 50),
                title: Text(widget.id),
                subtitle: Text(
                  DateFormat.yMMMMEEEEd().format(widget.dateTime).toString(),
                ),
                trailing: IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
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
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${prod.quantity.toStringAsFixed(0)} x   \$${prod.price.toStringAsFixed(2)}',
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
