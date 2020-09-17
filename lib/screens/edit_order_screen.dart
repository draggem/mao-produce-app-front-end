import 'package:flutter/material.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../widgets/order_product_list.dart';
import '../widgets/scaffold_body.dart';

import '../screens/product_screen.dart';
import '../screens/order_screen.dart';
import '../screens/signature_screen.dart';

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
  bool isEditing;
  bool perCust = false;
  String title;

  bool _orderStatus = true;

  final _form = GlobalKey<FormState>();

  var _initValues = {
    'custId': '',
    'custName': '',
    'id': null,
    'isOpen': true,
    'orderDate': '',
    'products': '',
    'totalPrice': '',
  };

  var _editedOrder = OrderAllModel(
    custId: '',
    custName: '',
    id: '',
    isOpen: false,
    orderDate: null,
    products: null,
    totalPrice: null,
  );

  //person who's signed
  var signee;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final order = ModalRoute.of(context).settings.arguments as List<String>;
      if (order[1] == 'selection') {
        var _editedCustomer = Provider.of<CustomerHttps>(context, listen: false)
            .findById(order[0]);
        _initValues = {
          'custId': _editedCustomer.id,
          'custName': _editedCustomer.name,
          'orderDate':
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        };

        //initialize order date
        _editedOrder.orderDate = DateTime.now();

        //initialise title
        title = 'Add an Order';
        //initialise form as adding product
        isEditing = false;
      } else {
        order.asMap().containsKey(2) && order[2] == "true"
            ? perCust = true
            : perCust = false;
        var selectedOrder =
            Provider.of<OrderHttps>(context, listen: false).findById(order[0]);
        _initValues = {
          'custId': selectedOrder.custId,
          'custName': selectedOrder.custName,
          'id': order[0],
          'isOpen': selectedOrder.isOpen,
          'orderDate': DateFormat.yMMMMEEEEd()
              .format(selectedOrder.orderDate)
              .toString(),
          'products': selectedOrder.products,
          'totalPrice': selectedOrder.totalPrice,
        };
        _orderStatus = selectedOrder.isOpen;
        signee = selectedOrder.signature['signee'] == null
            ? ''
            : selectedOrder.signature['signee'];

        //initialise form as adding product
        isEditing = true;

        //initialise title for edit
        title = '${selectedOrder.custName}';

        //initialise order date if order is under edit
        _editedOrder.orderDate = selectedOrder.orderDate;
      }
    }
    super.didChangeDependencies();
  }

  Future<void> _saveForm(bool isEmail) async {
    final productListProv =
        Provider.of<AddingProductOrder>(context, listen: false);

    List<OrderProductModel> productList = [];

    var signature;

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

    //get and check saved signature
    signature = productListProv.sign;

    var totalprice = productListProv.totalPrice();
    final isValid = _form.currentState.validate();

    if (productList.isEmpty) {
      _showErrorDialog('Please select Products for the Order');
      return;
    } else if (!isValid) {
      _showErrorDialog('Form is incomplete');
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();
    //add product inside
    _editedOrder.products = productList;
    //add total price inside
    _editedOrder.totalPrice = totalprice;

    try {
      if (!isEditing && !isEmail) {
        await Provider.of<OrderHttps>(context, listen: false)
            .addOrder(_editedOrder, signature, signee);
      } else if (isEditing && !isEmail) {
        await Provider.of<OrderHttps>(context, listen: false)
            .updateOrder(_editedOrder, signature, signee);
      } else {
        await Provider.of<OrderHttps>(context, listen: false)
            .sendEmail(_editedOrder, signature, signee, isEditing);
      }
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
    //added notation whether its from cust->order screen or just order screen.
    !perCust
        ? Navigator.of(context).pushNamedAndRemoveUntil(
            OrderScreen.routeName,
            ModalRoute.withName(OrderScreen.routeName),
          )
        : Navigator.of(context).pushNamedAndRemoveUntil(
            OrderScreen.routeName, ModalRoute.withName(OrderScreen.routeName),
            arguments: [_editedOrder.custId, _editedOrder.custName, true]);
    Navigator.of(context).pop();
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

  void _warningMsg() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Warning', style: TextStyle(color: Colors.white)),
        content: Text(
          'Any products added will not be saved',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Go Back',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _sendEmail() {
    Vibration.vibrate(duration: 500);
    var _isLoading = false;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 0,
              title: _isLoading
                  ? Text('')
                  : Text(
                      'Attention',
                      style: TextStyle(color: Colors.white),
                    ),
              backgroundColor: _isLoading ? Colors.transparent : Colors.orange,
              content: _isLoading
                  ? Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          strokeWidth: 9,
                        ),
                      ),
                    )
                  : Text('This will send an email to the customer',
                      style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                FlatButton(
                    child: _isLoading
                        ? Text('')
                        : Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                    onPressed: () {
                      _saveForm(true);
                      Navigator.of(context).pop();
                    }),
                FlatButton(
                  child: _isLoading
                      ? Text('')
                      : Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSign = false;
    var provider = Provider.of<AddingProductOrder>(context);

    if (provider.sign != null) {
      setState(() {
        isSign = true;
      });
    }
    return ScaffoldBody(
      appBarLeading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: _warningMsg,
      ),
      elevation: 0,
      scaffoldBackground: Theme.of(context).primaryColor,
      title: title,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.email),
          onPressed: _sendEmail,
        ),
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () => _saveForm(false),
        ),
      ],
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
                            id: _initValues['id'],
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
                            return 'There has to be a Date!';
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
                            id: _initValues['id'],
                            isOpen: _editedOrder.isOpen,
                            orderDate: _editedOrder.orderDate,
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
                              id: _initValues['id'],
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

                    TextFormField(
                        initialValue: signee,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orangeAccent,
                            ),
                          ),
                          labelText: 'Signee:',
                          labelStyle: TextStyle(color: Colors.white),
                          icon: Icon(Icons.person_outline,
                              color: Colors.orangeAccent),
                        ),
                        onSaved: (value) {
                          signee = value;
                        }),
                    SizedBox(
                      height: 30,
                    ),
                    FlatButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(SignatureScreen.routeName);
                        },
                        icon: Icon(Icons.person, color: Colors.white),
                        label: Text(
                          isSign
                              ? 'This order has been Signed'
                              : 'This order has no Signature',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: isSign ? Colors.orange : Colors.red),
                    SizedBox(height: 10),
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
                    SizedBox(height: 8),
                    OrderProductList(),
                  ],
                ),
              ),
            ),
    );
  }
}
