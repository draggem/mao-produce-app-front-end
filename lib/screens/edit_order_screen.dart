import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/order_product_list.dart';

import '../screens/product_screen.dart';

import '../providers/customer_https.dart';
import '../providers/adding_product_order.dart';
import '../providers/order_https.dart';

import '../models/order_all_model.dart';
import '../models/order_product_model.dart';

class EditOrderScreen extends StatefulWidget {
  static const routeName = '/edit-order';
  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  String title = 'Add an Order';
  bool _orderStatus;

  final _form = GlobalKey<FormState>();

  var _editedOrder = OrderAllModel(
    custId: '',
    custName: '',
    id: '',
    isOpen: false,
    orderDate: DateTime.now(),
    products: null,
    totalPrice: null,
  );

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
          'orderDate':
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        };
      }
    }
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final productListProv =
        Provider.of<AddingProductOrder>(context, listen: false);

    List<OrderProductModel> productList = [];

    print(_editedOrder.id);

    //for each function to add products inside the productList to put inside
    //the _editedOrder product
    productListProv.items.forEach(
      (key, value) => productList.add(
        OrderProductModel(
          quantity: value.quantity,
          id: value.id,
          price: value.price,
          title: value.title,
        ),
      ),
    );

    var totalprice = productListProv.totalPrice();
    final isValid = _form.currentState.validate();

    //Check if form is valid
    if (!isValid) {
      return;
    }
    if (productList.isEmpty) {
      _showErrorDialog('Please select Products for the Order');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    print(_editedOrder.id);
    //add product inside
    _editedOrder.products = productList;
    //add total price inside
    _editedOrder.totalPrice = totalprice;

    try {
      await Provider.of<OrderHttps>(context, listen: false)
          .addOrder(_editedOrder);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.toString());
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 20),
                    TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        enabled: false,
                        initialValue: _initValues['custName'],
                        validator: (value) {
                          if (value == '') {
                            return 'Please select a Customer';
                          }
                          return null;
                        },
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
                        onSaved: (value) {
                          _editedOrder = OrderAllModel(
                            custId: _initValues['custId'],
                            custName: value,
                            id: _editedOrder.id,
                            isOpen: _editedOrder.isOpen,
                            orderDate: _editedOrder.orderDate,
                            products: _editedOrder.products,
                            totalPrice: _editedOrder.totalPrice,
                          );
                        }),
                    SizedBox(height: 40),
                    //This is the dropdown for order status
                    TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        enabled: false,
                        initialValue: _initValues['orderDate'],
                        validator: (value) {
                          if (value == '') {
                            return 'Please select a Customer';
                          }
                          return null;
                        },
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
                        onSaved: (value) {
                          _editedOrder = OrderAllModel(
                            custId: _initValues['custId'],
                            custName: _editedOrder.custName,
                            id: _editedOrder.id,
                            isOpen: _editedOrder.isOpen,
                            orderDate: DateTime.now(),
                            products: _editedOrder.products,
                            totalPrice: _editedOrder.totalPrice,
                          );
                        }),
                    SizedBox(height: 40),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: DropDownFormField(
                          validator: (value) {
                            if (value == null) {
                              return ' Select a Status!!';
                            }
                            return null;
                          },
                          hintText: 'Select an Order status',
                          required: true,
                          titleText: 'Order Status',
                          value: _orderStatus,
                          onSaved: (value) {
                            setState(() {
                              _orderStatus = value;
                            });

                            _editedOrder = OrderAllModel(
                              custId: _initValues['custId'],
                              custName: _editedOrder.custName,
                              id: _editedOrder.id,
                              isOpen: value,
                              orderDate: _editedOrder.orderDate,
                              products: _editedOrder.products,
                              totalPrice: _editedOrder.totalPrice,
                            );
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
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              ProductScreen.routeName,
                              arguments: true);
                        },
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
