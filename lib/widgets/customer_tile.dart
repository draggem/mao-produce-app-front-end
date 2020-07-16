import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../screens/edit_customer_screen.dart';

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
          onTap: () {},
        ),
      ],
    );
  }
}
