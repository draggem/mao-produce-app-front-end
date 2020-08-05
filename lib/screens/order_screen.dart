import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_https.dart';

import '../models/order_product_model.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_tile_customer.dart';

enum FilterOptions { Open, All }

class OrderScreen extends StatefulWidget {
  //route name
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String custId = " ";

  var _showOnlyOpen = false;
  var _isInit = true;

//checks if I get customer id opening this screen
  @override
  void didChangeDependencies() {
    if (_isInit) {
      custId = ModalRoute.of(context).settings.arguments as String;
    }

    super.didChangeDependencies();
  }

//refresh orders function
  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<OrderHttps>(context, listen: false)
        .fetchAndSetOrder(custId, true);
  }

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
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshOrders(context),
                    child: Consumer<OrderHttps>(
                      builder: (ctx, orderData, _) => Padding(
                        padding: EdgeInsets.all(5),
                        child: ListView.builder(
                          itemCount: orderData.items.length,
                          itemBuilder: (_, i) => OrderTileCustomer(
                            id: orderData.items[i].id,
                            dateTime: orderData.items[i].orderDate,
                            isOpen: orderData.items[i].isOpen,
                            totalprice: orderData.items[i].totalPrice,
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
