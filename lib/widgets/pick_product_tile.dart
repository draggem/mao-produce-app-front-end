import 'package:flutter/material.dart';

import '../widgets/form_dialog.dart';

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
  void _confirmAdd() {
    showDialog(
        context: context,
        builder: (ctx) => FormDialog(
              price: widget.price,
              qty: widget.qty,
              id: widget.id,
              title: widget.title,
              context: context,
            ));
  }

  bool isDouble(String value) {
    if (value == null) {
      return false;
    }
    return double.parse(value, (e) => null) != null;
  }

  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
        trailing: FlatButton(
          splashColor: Colors.yellow,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
          onPressed: _confirmAdd,
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Text('\$${widget.price.toStringAsFixed(2)}'),
      ),
    );
  }
}
