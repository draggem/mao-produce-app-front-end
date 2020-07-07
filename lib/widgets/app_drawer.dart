import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_service.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Options'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');

                Provider.of<UserService>(context, listen: false).signOut();
              })
        ],
      ),
    );
  }
}
