import 'package:flutter/material.dart';

import '../models/products_model.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  String title = 'Add A Product';

  final _titleFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _imgUrlFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  final _imgUrlController = TextEditingController();

  var _editedProduct = ProductsModel(
    id: null,
    title: '',
    price: 0,
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

//dispose focus nodes
  @override
  void dispose() {
    _imgUrlFocusNode.removeListener(_updateImageUrl);
    _titleFocusNode.dispose();
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

  Future<void> _saveForm() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
