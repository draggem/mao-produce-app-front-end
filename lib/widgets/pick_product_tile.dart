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
  double editedQty = 1;
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final addOrderProvider = Provider.of<AddingProductOrder>(context);

    double editedPrice = widget.price;

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
            _checked = value;
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
                  editedPrice = double.parse(value);
                  print(editedPrice);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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
                onChanged: (value) => editedQty = double.parse(value),
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
