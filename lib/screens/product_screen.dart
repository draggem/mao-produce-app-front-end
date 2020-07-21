import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class ProductScreen extends StatelessWidget {
  static const routeName = '/product';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
