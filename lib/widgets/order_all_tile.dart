import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mao_produce/providers/adding_product_order.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../providers/order_https.dart';
import '../providers/adding_product_order.dart';

import '../screens/order_screen.dart';
import '../screens/edit_order_screen.dart';

class OrderAllTile extends StatefulWidget {
  final String custId;
  final String custName;
  final String id;
  final double totalPrice;
  final DateTime dateTime;
  final bool isOpen;
  final List<dynamic> products;
  final Map<String, String> signature;

  OrderAllTile({
    this.custId,
    this.custName,
    this.id,
    this.totalPrice,
    this.dateTime,
    this.isOpen,
    this.products,
    this.signature,
  });

  @override
  _OrderAllTileState createState() => _OrderAllTileState();
}

class _OrderAllTileState extends State<OrderAllTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    void _confirmDelete() {
      Vibration.vibrate(duration: 500);
      var _isLoading = false;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                elevation: 0,
                title: _isLoading
                    ? Text('')
                    : Text(
                        'Warning',
                        style: TextStyle(color: Colors.white),
                      ),
                backgroundColor: _isLoading ? Colors.transparent : Colors.red,
                content: _isLoading
                    ? Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            strokeWidth: 9,
                          ),
                        ),
                      )
                    : Text('Are you sure you want to remove this Order?',
                        style: TextStyle(color: Colors.white)),
                actions: <Widget>[
                  FlatButton(
                    child: _isLoading
                        ? Text('')
                        : Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                      child: _isLoading
                          ? Text('')
                          : Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await Provider.of<OrderHttps>(context, listen: false)
                              .deleteOrder(widget.id, widget.custId);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(OrderScreen.routeName);
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.of(context).pop();

                          scaffold.showSnackBar(SnackBar(
                            content: Text(
                              'Deleting Failed!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }),
                ],
              );
            },
          );
        },
      );
    }

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
                    Text(widget.id),
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
          onTap: () {
            //initialise provider
            var provider =
                Provider.of<AddingProductOrder>(context, listen: false);
            //add products for selected order
            provider.clear();
            widget.products.forEach((element) => provider.addProduct(element));
            if (widget.signature['signature'] != null) {
              provider.addSign(widget.signature['signature']);
            }

            List<String> arg = [widget.id, 'edit'];
            Navigator.of(context)
                .pushNamed(EditOrderScreen.routeName, arguments: arg);
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: _confirmDelete,
        ),
      ],
    );
  }
}
