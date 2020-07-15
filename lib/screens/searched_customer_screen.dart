import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/customer_https.dart';

import '../widgets/customer_tile.dart';

class SearchedCustomerScreen extends StatefulWidget {
  //route name
  static const routeName = '/searchedCustomer';

  @override
  _SearchedCustomerScreenState createState() => _SearchedCustomerScreenState();
}

class _SearchedCustomerScreenState extends State<SearchedCustomerScreen> {
  @override
  Widget build(BuildContext context) {
    //navigator reciever
    final customerName = ModalRoute.of(context).settings.arguments as String;

    //provider for customerData
    final customerProvider = Provider.of<CustomerHttps>(context);
    final customerData = customerProvider.findByName(customerName);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Results for $customerName',
          overflow: TextOverflow.fade,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
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
