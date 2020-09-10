import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_https.dart';

import '../widgets/order_all_tile.dart';
import '../widgets/order_tile_customer.dart';
import '../widgets/scaffold_body.dart';

class SearchedOrderScreen extends StatefulWidget {
  //route name
  static const routeName = '/searchedOrder';

  @override
  _SearchedOrderScreenState createState() => _SearchedOrderScreenState();
}

class _SearchedOrderScreenState extends State<SearchedOrderScreen> {
  @override
  Widget build(BuildContext context) {
    //navigator reciever
    final query = ModalRoute.of(context).settings.arguments as List;

    //provider for customerData
    final orderProvider = Provider.of<OrderHttps>(context);

    var searchedData;

    return ScaffoldBody(
      centerTitle: true,
      title: 'Results for ${query[0]}',
      titleOverflow: true,
      body: (() {
        switch (query[1]) {
          case 'customerOrder':
            {
              searchedData = orderProvider.findByQuery(query[0]);
              return Padding(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: searchedData.length,
                  itemBuilder: (_, i) => OrderTileCustomer(
                    dateTime: searchedData[i].orderDate,
                    id: searchedData[i].id,
                    isOpen: searchedData[i].isOpen,
                    products: searchedData[i].products,
                    totalPrice: searchedData[i].totalPrice,
                  ),
                ),
              );
            }
            break;
          case 'allOrder':
            {
              searchedData = orderProvider.findByQuery(query[0]);
              return Padding(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: searchedData.length,
                  itemBuilder: (_, i) => OrderAllTile(
                    custId: searchedData[i].custId,
                    custName: searchedData[i].custName,
                    dateTime: searchedData[i].orderDate,
                    id: searchedData[i].id,
                    isOpen: searchedData[i].isOpen,
                    products: searchedData[i].products,
                    totalPrice: searchedData[i].totalPrice,
                  ),
                ),
              );
            }
            break;
        }
      }()),
    );
  }
}
