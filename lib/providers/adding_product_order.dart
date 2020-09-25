import 'package:flutter/material.dart';

import '../models/order_product_model.dart';

class AddingProductOrder with ChangeNotifier {
  Map<String, OrderProductModel> _items = {};

  Map<String, OrderProductModel> get items {
    return {..._items};
  }

  get sign {
    return signature;
  }

  //signature
  var signature;

  //add a signature
  void addSign(var sign) {
    signature = sign;
    notifyListeners();
  }

//function to add product
  void addProduct(OrderProductModel order) {
    //checks if products is in the list or not
    if (_items.containsKey(order.id)) {
      _items.update(
          order.id,
          (existingProduct) => OrderProductModel(
                id: existingProduct.id,
                price: order.price,
                title: existingProduct.title,
                quantity: existingProduct.quantity += order.quantity,
              ));
    } else {
      _items.putIfAbsent(
        order.id,
        () => OrderProductModel(
          id: order.id,
          quantity: order.quantity,
          price: order.price,
          title: order.title,
        ),
      );
    }
    notifyListeners();
  }

//function to remove product
  void removeProduct(String id) {
    _items.remove(id);

    notifyListeners();
  }

//calculates the total price
  double totalPrice() {
    double price = 0;

    _items.forEach(
      (key, element) => {price += element.quantity * element.price},
    );

    return price;
  }

  //clear order and signature
  void clear() {
    _items = {};
    signature = null;
    notifyListeners();
  }

  //check if a product is already added
  bool isProductAdded(String id) {
    if (_items.containsKey(id)) {
      return true;
    } else {
      return false;
    }
  }
}
