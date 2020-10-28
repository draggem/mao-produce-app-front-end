import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/menu_screen.dart';

import '../providers/user_service.dart';

import '../models/options.dart';

import './drawer_item.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text('Options'),
              automaticallyImplyLeading: false,
            ),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: OPTIONS.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    DrawerItem(
                      OPTIONS[i].routeName,
                      OPTIONS[i].title,
                      OPTIONS[i].icon,
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Main Menu'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed(MenuScreen.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');

                Provider.of<UserService>(context, listen: false).checkTokenExpiry();
              },
            )
          ],
        ),
      ),
    );
  }
}
