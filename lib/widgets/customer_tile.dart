import 'package:flutter/material.dart';

class CustomerTile extends StatelessWidget {
  final String id;
  final String name;

  CustomerTile(
    this.id,
    this.name,
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      child: ListTile(
        title: Center(child: Text(name)),
      ),
      background: Container(
          color: Colors.orangeAccent,
          child: Padding(
              padding: EdgeInsets.only(left: 10), child: Icon(Icons.edit)),
          alignment: AlignmentDirectional.centerStart),
      secondaryBackground: Container(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(Icons.delete),
        ),
        alignment: AlignmentDirectional.centerEnd,
      ),
      key: Key(id),
      onDismissed: (direction) {},
    );
  }
}
