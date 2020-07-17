import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../screens/edit_customer_screen.dart';
import '../screens/customer_screen.dart';

import '../providers/customer_https.dart';

class CustomerTile extends StatelessWidget {
  final String id;
  final String name;

  CustomerTile(
    this.id,
    this.name,
  );

//Generates a list tile of a customer sent by customer_screen
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    void _confirmDelete() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            backgroundColor: Colors.orange,
            title: Text(
              'Warning:',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  try {
                    await Provider.of<CustomerHttps>(context, listen: false)
                        .deleteCustomer(id);
                    Navigator.of(ctx).pushNamed(CustomerScreen.routeName);
                  } catch (error) {
                    Navigator.of(ctx).pop();
                    scaffold.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          'Deleting Failed',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
              ),
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ]),
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
            child: Text('${name[0]}'),
            foregroundColor: Colors.white,
          ),
          title: Center(child: Text(name)),
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
                .pushNamed(EditCustomerScreen.routeName, arguments: id);
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
