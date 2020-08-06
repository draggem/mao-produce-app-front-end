import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_https.dart';

import '../models/order_product_model.dart';

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

  var appBarTitle = 'Orders';

  var _showOnlyOpen = true;
  var _isInit = true;

//checks if I get customer id opening this screen
  @override
  void didChangeDependencies() {
    if (ModalRoute.of(context).settings.arguments != null) {
      final arg = ModalRoute.of(context).settings.arguments as List;
      if (arg.length == 2) {
        setState(() {
          custId = arg[0];
          appBarTitle = '${arg[1]} Orders';
        });
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

//refresh orders function
  Future<void> _refreshOrders(BuildContext context) async {
    if (ModalRoute.of(context).settings.arguments != null) {
      await Provider.of<OrderHttps>(context, listen: false)
          .fetchAndSetOrder(custId, _showOnlyOpen);
    } else {
      await Provider.of<OrderHttps>(context, listen: false)
          .fetchAndSetAllOrder(_showOnlyOpen);
    }
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
          IconButton(icon: Icon(Icons.search), onPressed: () {})
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshOrders(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
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
                                    id: orderData.items[i].id,
                                    dateTime: orderData.items[i].orderDate,
                                    isOpen: orderData.items[i].isOpen,
                                    totalPrice: orderData.items[i].totalPrice,
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
    );
  }
}
