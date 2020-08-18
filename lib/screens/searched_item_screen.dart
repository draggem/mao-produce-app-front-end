import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_https.dart';
import '../providers/product_https.dart';

import '../widgets/customer_tile.dart';
import '../widgets/product_tile.dart';
import '../widgets/pick_product_tile.dart';

class SearchedItemScreen extends StatefulWidget {
  //route name
  static const routeName = '/searchedCustomer';

  @override
  _SearchedItemScreenState createState() => _SearchedItemScreenState();
}

class _SearchedItemScreenState extends State<SearchedItemScreen> {
  @override
  Widget build(BuildContext context) {
    //navigator reciever
    final query = ModalRoute.of(context).settings.arguments as List;

    //provider for customerData
    final customerProvider = Provider.of<CustomerHttps>(context);
    final productProvider = Provider.of<ProductHttps>(context);

    var searchedData;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Results for ${query[0]}',
          overflow: TextOverflow.fade,
        ),
      ),
      body: (() {
        switch (query[1]) {
          case 'customer':
            {
              searchedData = customerProvider.findByName(query[0]);
              return Padding(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: searchedData.length,
                  itemBuilder: (_, i) => CustomerTile(
                    id: searchedData[i].id,
                    name: searchedData[i].name,
                  ),
                ),
              );
            }
            break;
          case 'product':
            {
              searchedData = productProvider.findByName(query[0]);
              return Padding(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: searchedData.length,
                  itemBuilder: (_, i) => ProductTile(
                      id: searchedData[i].id,
                      title: searchedData[i].title,
                      price: searchedData[i].price,
                      imgUrl: searchedData[i].url),
                ),
              );
            }
            break;
          case 'productPicking':
            {
              searchedData = productProvider.findByName(query[0]);
              return Padding(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  itemCount: searchedData.length,
                  itemBuilder: (_, i) => PickProductTile(
                    id: searchedData[i].id,
                    title: searchedData[i].title,
                    price: searchedData[i].price,
                  ),
                ),
              );
            }
            break;
        }
        return null;
      }()),
    );
  }
}
