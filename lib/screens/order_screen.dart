import 'package:flutter/material.dart';

enum FilterOptions { Open, All }

class OrderScreen extends StatefulWidget {
  //route name
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var _showOnlyOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Orders'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Open) {
                  _showOnlyOpen = true;
                } else {
                  _showOnlyOpen = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Open,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
