import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../screens/edit_product_screen.dart';
import '../screens/product_screen.dart';

import '../providers/product_https.dart';

class ProductTile extends StatefulWidget {
  final String id;
  final String title;
  final double price;
  final String imgUrl;

  ProductTile({
    this.id,
    this.title,
    this.price,
    this.imgUrl,
  });

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
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
                    : Text('Are you sure you want to remove this customer?',
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
                          await Provider.of<ProductHttps>(context,
                                  listen: false)
                              .deleteProduct(widget.id);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(ProductScreen.routeName);
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
      child: Container(
        color: Colors.white,
        child: ListTile(
          onTap: () {},
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: widget.imgUrl == ''
                ? AssetImage('assets/img/MenuLogo.png')
                : NetworkImage(widget.imgUrl),
          ),
          trailing: Text('\$ ${widget.price.toStringAsFixed(2)}'),
          title: Center(
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
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
            Navigator.of(context)
                .pushNamed(EditProductScreen.routeName, arguments: widget.id);
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
