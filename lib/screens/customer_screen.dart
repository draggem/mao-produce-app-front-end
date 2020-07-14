import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_https.dart';

import '../widgets/app_drawer.dart';
import '../widgets/customer_tile.dart';

import '../models/customer_model.dart';
import '../models/options.dart';

class CustomerScreen extends StatelessWidget {
  //route name
  static const routeName = '/customer';

  @override
  Widget build(BuildContext context) {
    //provider for customerData
    final customerProvider = Provider.of<CustomerHttps>(context);
    final customerData = customerProvider.items;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Customers'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: customerData.length,
          itemBuilder: (_, i) => CustomerTile(
            customerData[i].id,
            customerData[i].name,
          ),
        ),
      ),
    );
  }
}

//-------------------------------SearchBar Class-------------------------------------------------------------
class DataSearch extends SearchDelegate<String> {
  final recent = [
    'George Somoso',
    'Vincent Chen',
    'Vaughn Gigataras',
    'Hsin-Chen Tsai',
  ];

  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.white,
      textTheme: theme.textTheme.copyWith(
        headline6: theme.textTheme.headline6.copyWith(color: Colors.black),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for the appbar
    return [
      IconButton(
        color: Theme.of(context).primaryColor,
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: transitionAnimation,
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon(on the left of the app bar)
    return IconButton(
      color: Theme.of(context).primaryColor,
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Card(
      color: Colors.red,
      child: Center(
        child: Text(query),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final customerData = Provider.of<CustomerHttps>(context);
    final customerList = [];
    final customerMap = [];

    for (var i = 0; i < customerData.items.length; i++) {
      var newMap = {
        'name': customerData.items[i].name,
        'id': customerData.items[i].id,
      };
      customerMap.add(newMap);
      customerList.add(
        customerData.items[i].name,
      );
    }

    final suggestionList = query.isEmpty
        ? recent
        : customerList
            .where(
              (input) => input.startsWith(
                RegExp(query, caseSensitive: false),
              ),
            )
            .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              //Function when data that is searched is tapped
              onTap: () {
                showResults(context);
              },
              leading: Icon(
                Icons.perm_identity,
                color: Theme.of(context).primaryColor,
              ),
              title: RichText(
                text: TextSpan(
                  text: customerMap[index]['name'].substring(0, query.length),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: customerMap[index]['name'].substring(query.length),
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
        itemCount: suggestionList.length);
  }
}
