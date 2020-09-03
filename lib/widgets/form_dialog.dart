import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/adding_product_order.dart';

import '../models/order_product_model.dart';

class FormDialog extends StatefulWidget {
  final qty;
  final price;
  final id;
  final title;
  final context;

  FormDialog({
    this.qty,
    this.price,
    this.id,
    this.title,
    this.context,
  });
  @override
  _FormDialogState createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;

  var product = OrderProductModel(
    quantity: null,
    id: '',
    price: null,
    title: '',
  );

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

  Future<void> _confirmAdd(ScaffoldState scaffold) async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    try {
      Provider.of<AddingProductOrder>(context, listen: false)
          .addProduct(product);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    scaffold.showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(
        'Product Added',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(widget.context);
    return AlertDialog(
        elevation: 0,
        title: _isLoading
            ? Text('')
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Confirm Product'),
                  IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ),
        backgroundColor:
            _isLoading ? Colors.transparent : Theme.of(context).primaryColor,
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
            : Container(
                height: 150,
                child: Form(
                  key: _form,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextFormField(
                            validator: (value) {
                              if (value == null) {
                                return 'Incorrect';
                              }
                              if (double.tryParse(value) == null) {
                                return "Incorrect";
                              }
                              return null;
                            },
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            initialValue: widget.qty.toStringAsFixed(0),
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'Qty:',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onSaved: (value) {
                              product = OrderProductModel(
                                quantity: double.parse(value),
                                id: widget.id,
                                price: product.price,
                                title: widget.title,
                              );
                            }),
                      ),
                      Flexible(
                        child: Container(
                          width: 50,
                          child: TextFormField(
                            enabled: false,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            initialValue: '@',
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextFormField(
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null) {
                                return 'Incorrect';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Incorrect';
                              }
                              return null;
                            },
                            initialValue: widget.price.toStringAsFixed(2),
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: '\$:',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            onSaved: (value) {
                              product = OrderProductModel(
                                quantity: product.quantity,
                                id: widget.id,
                                price: double.parse(value),
                                title: widget.title,
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
        actions: <Widget>[
          FlatButton(
            child: _isLoading
                ? Text('')
                : Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
            onPressed: () => _confirmAdd(scaffold),
          ),
        ]);
  }
}
