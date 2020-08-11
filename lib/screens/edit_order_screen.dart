import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/order_product_list.dart';

import '../providers/customer_https.dart';

class EditOrderScreen extends StatefulWidget {
  static const routeName = '/edit-order';
  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  String title = 'Add an Order';
  bool _orderStatus;

  final _form = GlobalKey<FormState>();

  var _editedOrder = {
    'custId': '',
    'custName': '',
    'id': null,
    'isOpen': true,
    'orderDate': DateTime.now(),
    'products': null,
    'totalPrice': null
  };

  var _initValues = {
    'custId': '',
    'custName': '',
    'id': null,
    'isOpen': true,
    'orderDate': DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
    'products': '',
    'totalPrice': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final customerId = ModalRoute.of(context).settings.arguments as String;
      if (customerId != null) {
        var _editedCustomer = Provider.of<CustomerHttps>(context, listen: false)
            .findById(customerId);
        _initValues = {
          'custId': _editedCustomer.id,
          'custName': _editedCustomer.name,
        };
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 7),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      enabled: false,
                      initialValue: _initValues['custId'],
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orangeAccent,
                          ),
                        ),
                        labelText: 'Customer ID',
                        labelStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.person, color: Colors.orangeAccent),
                      ),
                      cursorColor: Colors.white,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      enabled: false,
                      initialValue: _initValues['custName'],
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orangeAccent,
                          ),
                        ),
                        labelText: 'Customer Name',
                        labelStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.person, color: Colors.orangeAccent),
                      ),
                    ),
                    SizedBox(height: 40),
                    //This is the dropdown for order status
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      enabled: false,
                      initialValue: _initValues['orderDate'],
                      decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.orangeAccent,
                          ),
                        ),
                        labelText: 'Order Created On',
                        labelStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.calendar_today,
                            color: Colors.orangeAccent),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: DropDownFormField(
                          hintText: 'Select an Order status',
                          required: true,
                          titleText: 'Order Status',
                          value: _orderStatus,
                          onSaved: (value) {
                            setState(() {
                              _orderStatus = value;
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              _orderStatus = value;
                            });
                          },
                          dataSource: [
                            {
                              'display': 'Open',
                              'value': true,
                            },
                            {
                              'display': 'Close',
                              'value': false,
                            },
                          ],
                          textField: 'display',
                          valueField: 'value',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    OrderProductList(),
                    SizedBox(height: 4),
                    FlatButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add a Product',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orange),
                  ],
                ),
              ),
            ),
    );
  }
}
