import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/custom_icons_icons.dart';
import '../models/products_model.dart';

import '../providers/product_https.dart';

import '../screens/product_screen.dart';

import '../widgets/scaffold_body.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String title = 'Add A Product';

  final _priceFocusNode = FocusNode();
  final _imgUrlFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  final _imgUrlController = TextEditingController();

  var _editedProduct = ProductsModel(
    id: null,
    title: '',
    price: 0.00,
    url: '',
  );

  var _initValues = {
    'id': null,
    'title': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

//add listener to the image focus node
  @override
  void initState() {
    _imgUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

//Checks if you received an argument from navigator
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<ProductHttps>(context, listen: false)
            .findById(productId);
        title = 'Edit ${_editedProduct.title}';
        _initValues = {
          'id': _editedProduct.id,
          'title': _editedProduct.title,
          'price': _editedProduct.price.toStringAsFixed(2),
          'imageUrl': '',
        };
        _imgUrlController.text = _editedProduct.url;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

//dispose focus nodes
  @override
  void dispose() {
    _imgUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imgUrlFocusNode.dispose();
    super.dispose();
  }

//updates the image url so the image preview also gets updated
  void _updateImageUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if (!_imgUrlController.text.startsWith('http') ||
          !_imgUrlController.text.startsWith('https')) //||
      // !_imageUrlController.text.endsWith('.png') &&
      //     !_imageUrlController.text.endsWith('jpg') &&
      //    !_imageUrlController.text.endsWith('.jpeg'))
      {
        return;
      }
      setState(() {});
    }
  }

  //Show error pop up
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

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState.save();

    if (_editedProduct.id != null) {
      //call product update
      try {
        await Provider.of<ProductHttps>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(e.toString());
        return;
      }
      //if there are no errors go to product screen to reload
      setState(() {
        _isLoading = false;
      });
    } else {
      //call Add product
      try {
        await Provider.of<ProductHttps>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
        return;
      }
      //if there are no errors go to proct screen to reload
      setState(() {
        _isLoading = false;
      });
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      ProductScreen.routeName,
      ModalRoute.withName(ProductScreen.routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldBody(
      title: title,
      actions: [
        IconButton(icon: Icon(Icons.check), onPressed: _saveForm),
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
                      maxRadius: 150,
                      backgroundImage: _imgUrlController.text.isEmpty
                          ? AssetImage('assets/img/MenuLogo.png')
                          : NetworkImage(_imgUrlController.text),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(CustomIcons.leaf),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductsModel(
                          id: _editedProduct.id,
                          title: value,
                          price: _editedProduct.price,
                          url: _editedProduct.url,
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Product Price',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.attach_money),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      focusNode: _priceFocusNode,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (double.tryParse(value) == null) {
                          return "Please provide an appropriate price";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = ProductsModel(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: double.parse(value),
                            url: _editedProduct.url);
                      },
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image Url',
                        labelStyle: TextStyle(color: Colors.black),
                        icon: Icon(Icons.photo),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      focusNode: _imgUrlFocusNode,
                      controller: _imgUrlController,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value.startsWith('https') ||
                            value.startsWith('http') ||
                            value.isEmpty) {
                          return null;
                        } else {
                          return 'the link needs \'http\' or \'https\' in the beginning';
                        }
                      },
                      onSaved: (value) {
                        _editedProduct = ProductsModel(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            url: value);
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
