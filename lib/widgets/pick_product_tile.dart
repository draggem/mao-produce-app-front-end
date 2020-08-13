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

  PickProductTile({
    this.id,
    this.title,
    this.price,
    this.qty = 1,
  });
  @override
  _PickProductTileState createState() => _PickProductTileState();
}

class _PickProductTileState extends State<PickProductTile> {
  bool _checked = false;
  double editedQty = 1;

  @override
  Widget build(BuildContext context) {
    final addOrderProvider = Provider.of<AddingProductOrder>(context);

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: CheckboxListTile(
        value: _checked,
        onChanged: (bool value) {
          setState(() {
            _checked = value;

            if (_checked) {
              addOrderProvider.addOrder(
                  OrderProductModel(
                    quantity: editedQty,
                    id: widget.id,
                    price: widget.price,
                    title: widget.title,
                  ),
                  widget.id,
                  editedQty);
            } else {
              addOrderProvider.removeProduct(widget.id);
              print('removed');
            }
          });
        },
        subtitle: TextFormField(
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
        title: Text(
          '\$${widget.price.toStringAsFixed(2)} ${widget.title}',
        ),
      ),
    );
  }
}
