import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class OrderAllTile extends StatefulWidget {
  final String custId;
  final String custName;
  final String id;
  final double totalPrice;
  final DateTime dateTime;
  final bool isOpen;
  final List<dynamic> products;

  OrderAllTile({
    this.custId,
    this.custName,
    this.id,
    this.totalPrice,
    this.dateTime,
    this.isOpen,
    this.products,
  });

  @override
  _OrderAllTileState createState() => _OrderAllTileState();
}

class _OrderAllTileState extends State<OrderAllTile> {
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
                title: Text(widget.custName, maxLines: 1),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(widget.dateTime).toString(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${widget.id.substring(0, 6)}',
                      overflow: TextOverflow.fade,
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
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity.toStringAsFixed(0)}x   \$${prod.price.toStringAsFixed(2)}',
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
