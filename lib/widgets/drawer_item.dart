import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String routeName;
  final String title;
  final IconData icon;

  DrawerItem(this.routeName, this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (routeName == null) {
          return;
        } else {
          //removes previous routes
          Navigator.of(context).pushNamedAndRemoveUntil(
              routeName, ModalRoute.withName(routeName));
        }
      },
    );
  }
}
