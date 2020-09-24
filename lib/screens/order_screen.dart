import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_service.dart';
import '../providers/order_https.dart';
import '../providers/recent_searches.dart';
import '../providers/adding_product_order.dart';

import '../models/order_product_model.dart';

import '../screens/searched_order_screen.dart';
import '../screens/customer_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_tile_customer.dart';
import '../widgets/order_all_tile.dart';

enum FilterOptions { Open, All }

class OrderScreen extends StatefulWidget {
  //route name
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String custId = " ";
  String custName = " ";
  static bool isFromCustomers = false;

  var appBarTitle = 'Orders';

  var _showOnlyOpen = true;
  var _isInit = true;

//checks if I get customer id opening this screen
  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context).settings.arguments != null) {
      final arg = ModalRoute.of(context).settings.arguments as List;
      if (arg.length == 3) {
        setState(() {
          custId = arg[0];
          custName = '${arg[1]}';
          appBarTitle = '$custName\'s Orders';
          isFromCustomers = arg[2];
        });
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

//refresh orders function
  Future<void> _refreshOrders(BuildContext context) async {
    try {
      if (ModalRoute.of(context).settings.arguments != null) {
        await Provider.of<OrderHttps>(context, listen: false)
            .fetchAndSetOrder(custId, _showOnlyOpen);
      } else {
        await Provider.of<OrderHttps>(context, listen: false)
            .fetchAndSetAllOrder(_showOnlyOpen);
      }
    } catch (e) {
      var provider = Provider.of<UserService>(context, listen: false);
      await provider.tryAutoLogin() == false
          ? Navigator.of(context).pushReplacementNamed('/')
          : _showErrorDialog(context, e.toString());
      _showErrorDialog(context, e);
    }
  }

  //error dialog
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(appBarTitle),
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
                child: Text('Open Orders'),
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
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshOrders(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: Image(
                  image: AssetImage('assets/img/LoadingCartoon.gif'),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshOrders(context),
                child: Consumer<OrderHttps>(
                  builder: (ctx, orderData, _) => orderData.items.length == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Image(
                                image: AssetImage('assets/img/NoOrder.gif'),
                              ),
                            ),
                            Container(
                              child: Text(
                                'There are no Orders...',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.all(5),
                          child: custId == " "
                              ? ListView.builder(
                                  itemCount: orderData.items.length,
                                  itemBuilder: (_, i) => OrderAllTile(
                                    custId: orderData.items[i].custId,
                                    custName: orderData.items[i].custName,
                                    id: orderData.items[i].id,
                                    dateTime: orderData.items[i].orderDate,
                                    isOpen: orderData.items[i].isOpen,
                                    totalPrice: orderData.items[i].totalPrice,
                                    signature: orderData.items[i].signature,
                                    products: orderData.items[i].products
                                        .map(
                                          (prod) => OrderProductModel(
                                            quantity: prod.quantity,
                                            id: prod.id,
                                            price: prod.price,
                                            title: prod.title,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: orderData.items.length,
                                  itemBuilder: (_, i) => OrderTileCustomer(
                                    custId: orderData.items[i].custId,
                                    custName: orderData.items[i].custName,
                                    id: orderData.items[i].id,
                                    dateTime: orderData.items[i].orderDate,
                                    isOpen: orderData.items[i].isOpen,
                                    totalPrice: orderData.items[i].totalPrice,
                                    signature: orderData.items[i].signature,
                                    products: orderData.items[i].products
                                        .map(
                                          (prod) => OrderProductModel(
                                            quantity: prod.quantity,
                                            id: prod.id,
                                            price: prod.price,
                                            title: prod.title,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                        ),
                ),
              ),
      ),
      floatingActionButton: custId == " "
          ? FloatingActionButton(
              onPressed: () {
                //initialise provider
                var provider =
                    Provider.of<AddingProductOrder>(context, listen: false);
                //add products for selected order
                provider.clear();
                Navigator.of(context)
                    .pushNamed(CustomerScreen.routeName, arguments: true);
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
    final orderData = Provider.of<OrderHttps>(context).findByQuery(query);
    final customerList = [];

    for (var i = 0; i < orderData.length; i++) {
      customerList.add('${orderData[i].id}' +
          ' ${orderData[i].custName == null ? ' ' : orderData[i].custName}' +
          ' ${DateFormat('dd/MM/yyyy').format(orderData[i].orderDate).toString()}' +
          ' \$${orderData[i].totalPrice.toStringAsFixed(2)}');
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
                  _OrderScreenState.isFromCustomers == true
                      ? 'customerOrder'
                      : 'allOrder'
                ];
                Navigator.of(context).pushNamed(SearchedOrderScreen.routeName,
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
    final orderData = Provider.of<OrderHttps>(context);
    final orderList = [];

    for (var i = 0; i < orderData.items.length; i++) {
      orderList.add('${orderData.items[i].id}' +
          ' ${orderData.items[i].custName == null ? ' ' : orderData.items[i].custName}' +
          ' ${DateFormat('dd/MM/yyyy').format(orderData.items[i].orderDate).toString()}' +
          ' \$${orderData.items[i].totalPrice.toStringAsFixed(2)}');
    }

    final suggestionList = query.isEmpty
        ? recent
        : orderList
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
                _OrderScreenState.isFromCustomers == true
                    ? 'customerOrder'
                    : 'allOrder'
              ];
              Navigator.of(context).pushNamed(SearchedOrderScreen.routeName,
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
