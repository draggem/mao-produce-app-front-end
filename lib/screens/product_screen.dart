import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/product_tile.dart';

import '../providers/product_https.dart';
import '../providers/recent_searches.dart';

import '../screens/searched_item_screen.dart';

class ProductScreen extends StatelessWidget {
  static const routeName = '/product';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<ProductHttps>(context, listen: false)
          .fetchAndSetProducts();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductHttps>(
                      builder: (ctx, productData, _) => Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          child: ListView.builder(
                            itemCount: productData.items.length,
                            itemBuilder: (_, i) => ProductTile(
                              id: productData.items[i].id,
                              title: productData.items[i].title,
                              price: productData.items[i].price,
                              imgUrl: productData.items[i].url,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.lightGreen[800]),
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
    final productData = Provider.of<ProductHttps>(context).findByName(query);
    final customerList = [];

    for (var i = 0; i < productData.length; i++) {
      customerList.add(
        productData[i].title + ' \$ ' + productData[i].price.toString(),
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
                final searchedData = [suggestionList[index], 'product'];
                Navigator.of(context).pushNamed(SearchedItemScreen.routeName,
                    arguments: searchedData);
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
    final productData = Provider.of<ProductHttps>(context);
    final customerList = [];

    for (var i = 0; i < productData.items.length; i++) {
      customerList.add(
        productData.items[i].title +
            ' \$ ' +
            productData.items[i].price.toString(),
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
              final searchedData = [suggestionList[index], 'product'];
              Navigator.of(context).pushNamed(SearchedItemScreen.routeName,
                  arguments: searchedData);
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
