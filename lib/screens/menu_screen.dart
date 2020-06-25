import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

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
        title: Text('Mao Produce'),
        elevation: 10,
      ),
      drawer: AppDrawer(),
    );
  }
}
