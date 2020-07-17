import 'package:flutter/material.dart';
import 'package:mao_produce/screens/edit_customer_screen.dart';
import 'package:provider/provider.dart';

import '../providers/customer_https.dart';
import '../providers/recent_searches.dart';

import '../widgets/app_drawer.dart';
import '../widgets/customer_tile.dart';

import '../screens/searched_customer_screen.dart';

class CustomerScreen extends StatelessWidget {
  //route name
  static const routeName = '/customer';

  Future<void> _refreshCustomers(BuildContext context) async {
    await Provider.of<CustomerHttps>(context, listen: false)
        .fetchAndSetCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Customers'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshCustomers(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshCustomers(context),
                    child: Consumer<CustomerHttps>(
                      builder: (ctx, customerData, _) => Padding(
                        padding: EdgeInsets.all(5),
                        child: ListView.builder(
                          itemCount: customerData.items.length,
                          itemBuilder: (_, i) => CustomerTile(
                            customerData.items[i].id,
                            customerData.items[i].name,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(EditCustomerScreen.routeName);
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }
}

//-------------------------------SearchBar Class-------------------------------------------------------------
class DataSearch extends SearchDelegate<String> {
  var recent = [];
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

//When search is entered on keyboard
  @override
  Widget buildResults(BuildContext context) {
    final recentSearchProvider = Provider.of<RecentSearches>(context);
    recent = recentSearchProvider.recentCustomers;
    final customerData = Provider.of<CustomerHttps>(context).findByName(query);
    final customerList = [];

    for (var i = 0; i < customerData.length; i++) {
      customerList.add(
        customerData[i].name,
      );
    }

    final suggestionList = query.isEmpty
        ? recent
        : customerList
            .where(
              (input) => input.contains(
                RegExp(query, caseSensitive: false),
              ),
            )
            .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              //Function when data that is searched is tapped
              onTap: () {
                Navigator.of(context).pushNamed(
                    SearchedCustomerScreen.routeName,
                    arguments: suggestionList[index]);
                recentSearchProvider.addRecent(suggestionList[index]);
              },
              leading: Icon(
                Icons.perm_identity,
                color: Theme.of(context).primaryColor,
              ),
              title: RichText(
                text: TextSpan(
                  text: suggestionList[index].substring(0, query.length),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: suggestionList[index].substring(query.length),
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
        itemCount: suggestionList.length);
  }

  //shows the suggestions based from what you typed on the search field

  @override
  Widget buildSuggestions(BuildContext context) {
    final recentSearchProvider = Provider.of<RecentSearches>(context);
    recent = recentSearchProvider.recentCustomers;
    final customerData = Provider.of<CustomerHttps>(context);
    final customerList = [];

    for (var i = 0; i < customerData.items.length; i++) {
      customerList.add(
        customerData.items[i].name,
      );
    }

    final suggestionList = query.isEmpty
        ? recent
        : customerList
            .where(
              (input) => input.contains(
                RegExp(query, caseSensitive: false),
              ),
            )
            .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
            //Function when data that is searched is tapped
            onTap: () {
              Navigator.of(context).pushNamed(SearchedCustomerScreen.routeName,
                  arguments: suggestionList[index]);
              recentSearchProvider.addRecent(suggestionList[index]);
            },
            leading: Icon(
              Icons.perm_identity,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              suggestionList[index],
              style: TextStyle(color: Theme.of(context).primaryColor),
            )),
        itemCount: suggestionList.length);
  }
}
