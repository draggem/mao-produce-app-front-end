import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../widgets/options_tile.dart';

import '../models/options.dart';

class MenuScreen extends StatefulWidget {
  static const routeName =
      '/menu'; //this is the route name to navigate to this screen.

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mao Produce'),
        elevation: 10,
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: <Widget>[
          GridView(
            padding: const EdgeInsets.all(15),
            children: OPTIONS
                .map(
                  (e) => OptionsTile(e.routeName, e.title, e.color, e.icon),
                )
                .toList(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 6 / 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 15,
            ),
          )
        ],
      ),
    );
  }
}
