import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/product_tile.dart';
import '../widgets/pick_product_tile.dart';
import '../widgets/scaffold_body.dart';

import '../providers/product_https.dart';
import '../providers/recent_searches.dart';
import '../providers/user_service.dart';
import '../screens/searched_item_screen.dart';
import '../screens/edit_product_screen.dart';

class ProductScreen extends StatefulWidget {
  static const routeName = '/product';

  //checks if you are selecting product or not
  static bool isProductAdding = false;

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String title = 'Products';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<ProductHttps>(context, listen: false)
          .fetchAndSetProducts();
    } on NoSuchMethodError catch (e) {
      var provider = Provider.of<UserService>(context, listen: false);
      await provider.init() == false
          ? Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false)
          : print("Hide this exception because its not really an error");
    } catch (e) {
      var provider = Provider.of<UserService>(context, listen: false);
      await provider.init() == false
          ? Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false)
          : _showErrorDialog(context, e.toString());
      _showErrorDialog(context, e);
    }
  }

//show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context).settings.arguments != null) {
      ProductScreen.isProductAdding =
          ModalRoute.of(context).settings.arguments as bool;
      title = 'Add A Product';
    } else {
      ProductScreen.isProductAdding = false;
      title = 'Products';
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      centerTitle: true,
      title: title,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: DataSearch());
          },
        ),
      ],
      drawer: ProductScreen.isProductAdding == true ? null : AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: Center(
                  child: Image(
                    image: AssetImage('assets/img/LoadingCartoon.gif'),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<ProductHttps>(
                    builder: (ctx, productData, _) =>
                        ProductScreen.isProductAdding == false
                            ? Padding(
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
                              )
                            : Padding(
                                padding: EdgeInsets.all(5),
                                child: Container(
                                  child: ListView.builder(
                                      itemCount: productData.items.length,
                                      itemBuilder: (_, i) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PickProductTile(
                                            id: productData.items[i].id,
                                            title: productData.items[i].title,
                                            price: productData.items[i].price,
                                          ),
                                        );
                                      }),
                                ),
                              )),
              ),
      ),
      floatingActionButton: ProductScreen.isProductAdding == false
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.lightGreen[800])
          : Container(),
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
        productData[i].title + ' \$' + productData[i].price.toString(),
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
                final searchedData = [
                  suggestionList[index],
                  ProductScreen.isProductAdding ? 'productPicking' : 'product'
                ];
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
            ' \$' +
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
              final searchedData = [
                suggestionList[index],
                ProductScreen.isProductAdding ? 'productPicking' : 'product',
              ];
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
