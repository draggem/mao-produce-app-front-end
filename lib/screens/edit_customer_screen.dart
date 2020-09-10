import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/customer_model.dart';

import '../providers/customer_https.dart';

import '../screens/customer_screen.dart';

import '../widgets/scaffold_body.dart';

class EditCustomerScreen extends StatefulWidget {
  static const routeName = '/edit-customer';

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  String title = 'Add A Customer';
  final _emailFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  var _editedCustomer = CustomerModel(
    id: null,
    name: '',
    email: '',
    address: '',
    phone: '',
    userDate: DateTime.now(),
  );

  var _initValues = {
    'id': null,
    'name': '',
    'email': '',
    'address': '',
    'phone': '',
    'createdTimeStamp':
        DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
  };

  var _isInit = true;
  var _isLoading = false;

//Dispose focus nodes avoiding simultaneous focus
  void dispose() {
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  //flutter function that runs after initialisation but before all the code
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final customerId = ModalRoute.of(context).settings.arguments as String;
      if (customerId != null) {
        _editedCustomer = Provider.of<CustomerHttps>(context, listen: false)
            .findById(customerId);

        title = 'Edit ${_editedCustomer.name}';
        _initValues = {
          'id': _editedCustomer.id,
          'name': _editedCustomer.name,
          'email': _editedCustomer.email,
          'address': _editedCustomer.address,
          'phone': _editedCustomer.phone,
          'createdTimeStamp': DateFormat.yMMMMEEEEd()
              .format(_editedCustomer.userDate)
              .toString(),
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

//Save function
  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    if (_editedCustomer.id != null) {
      try {
        await Provider.of<CustomerHttps>(context, listen: false)
            .updateCustomer(_editedCustomer.id, _editedCustomer);
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
      Navigator.of(context).pushNamed(CustomerScreen.routeName);
    } else {
      try {
        await Provider.of<CustomerHttps>(context, listen: false)
            .addCustomers(_editedCustomer);
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
      Navigator.of(context).pushReplacementNamed(CustomerScreen.routeName);
    }
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
    return ScaffoldBody(
      title: title,
      actions: [
        IconButton(
          icon: Icon(Icons.check),
          onPressed: _saveForm,
        )
      ],
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
                    SizedBox(height: 40),
                    CircleAvatar(
                      maxRadius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${_initValues['name'] == '' ? 'M' : _initValues['name'].toString()[0]}',
                        style: TextStyle(fontSize: 35),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.person),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedCustomer = CustomerModel(
                          id: _editedCustomer.id,
                          name: value,
                          email: _editedCustomer.email,
                          address: _editedCustomer.address,
                          phone: _editedCustomer.phone,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      initialValue: _initValues['email'],
                      decoration: InputDecoration(
                        labelText: 'Customer Email',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.mail),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      focusNode: _emailFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_addressFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Incorrect format';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedCustomer = CustomerModel(
                          id: _editedCustomer.id,
                          name: _editedCustomer.name,
                          email: value,
                          address: _editedCustomer.address,
                          phone: _editedCustomer.phone,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      initialValue: _initValues['address'],
                      decoration: InputDecoration(
                        labelText: 'Customer Address (optional)',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.location_on),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      focusNode: _addressFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_phoneFocusNode);
                      },
                      onSaved: (value) {
                        _editedCustomer = CustomerModel(
                          id: _editedCustomer.id,
                          name: _editedCustomer.name,
                          email: _editedCustomer.email,
                          address: value,
                          phone: _editedCustomer.phone,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      initialValue: _initValues['phone'],
                      decoration: InputDecoration(
                        labelText: 'Customer Phone No. (optional)',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.phone),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedCustomer = CustomerModel(
                          id: _editedCustomer.id,
                          name: _editedCustomer.name,
                          email: _editedCustomer.email,
                          address: _editedCustomer.address,
                          phone: value,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      initialValue: _initValues['createdTimeStamp'].toString(),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'User date created on',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.timer),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
