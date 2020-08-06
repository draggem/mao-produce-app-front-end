import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../screens/edit_customer_screen.dart';
import '../screens/customer_screen.dart';
import '../screens/order_screen.dart';

import '../providers/customer_https.dart';

class CustomerTile extends StatefulWidget {
  final String id;
  final String name;

  CustomerTile({
    this.id,
    this.name,
  });

  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {
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
                          await Provider.of<CustomerHttps>(context,
                                  listen: false)
                              .deleteCustomer(widget.id);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushNamed(CustomerScreen.routeName);
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
            backgroundColor: Theme.of(context).primaryColor,
            child: Text('${widget.name[0]}'),
            foregroundColor: Colors.white,
          ),
          title: Center(
            child: Text(
              widget.name,
            ),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          foregroundColor: Colors.white,
          caption: 'Orders',
          color: Colors.blue,
          icon: Icons.assignment,
          onTap: () {
            Navigator.of(context).pushNamed(OrderScreen.routeName,
                arguments: [widget.id, widget.name]);
          },
        ),
        IconSlideAction(
          foregroundColor: Colors.white,
          caption: 'Edit',
          color: Colors.orange,
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context)
                .pushNamed(EditCustomerScreen.routeName, arguments: widget.id);
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
