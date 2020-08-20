import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/order_product_model.dart';

import '../providers/adding_product_order.dart';

class PickProductTile extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final double qty;
  final bool checked;

  PickProductTile({
    this.id,
    this.title,
    this.price,
    this.qty = 1,
    this.checked,
  });
  @override
  _PickProductTileState createState() => _PickProductTileState();
}

class _PickProductTileState extends State<PickProductTile> {
  String editedQty = '1';
  bool _checked = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  bool isDouble(String value) {
    if (value == null) {
      return false;
    }
    print(double.parse(value, (e) => null) != null);
    return double.parse(value, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    final addOrderProvider = Provider.of<AddingProductOrder>(context);

    String editedPrice = widget.price.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: _checked,
        onChanged: (bool value) {
          setState(() {
            if (!isDouble(editedPrice.toString()) ||
                !isDouble(editedQty.toString())) {
              _checked = false;
              _showErrorDialog('Please enter a Numerical Value');
            } else {
              _checked = value;
              if (_checked) {
                addOrderProvider.addOrder(
                  OrderProductModel(
                    id: widget.id,
                    quantity: double.parse(editedQty),
                    price: double.parse(editedPrice),
                    title: widget.title,
                  ),
                );
              } else {
                addOrderProvider.removeProduct(widget.id);
              }
            }
          });
        },
        title: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(widget.title),
        ),
        subtitle: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                initialValue: widget.price.toStringAsFixed(2),
                onChanged: (value) {
                  editedPrice = value;
                },
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: '\$:',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: widget.qty.toStringAsFixed(0),
                onChanged: (value) => editedQty = value,
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                  labelText: 'Qty:',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
