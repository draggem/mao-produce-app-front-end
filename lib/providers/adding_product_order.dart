import 'package:flutter/material.dart';

import '../models/order_product_model.dart';

class AddingProductOrder with ChangeNotifier {
  List<OrderProductModel> _items = [];

  List<OrderProductModel> get items {
    return [..._items];
  }

//function to add product
  void addOrder(OrderProductModel order, String id, double quantity) {
    //checks if products is in the list or not
    bool isExist = false;

    if (_items.length != 0) {
      _items.forEach((element) {
        if (element.id == id) {
          element.quantity += quantity;
          isExist = true;
        } else {
          isExist = false;
        }
      });
    } else {
      _items.add(order);
      return;
    }

    if (isExist == false) {
      _items.add(order);
    }
    print(_items);
    notifyListeners();
  }

//function to remove product
  void removeProduct(String id) {
    _items.removeWhere((product) => product.id == id);

    notifyListeners();
    print(items);
  }

//calculates the total price
  double totalPrice() {
    double price = 0;
    if (items.isNotEmpty) {
      items.forEach((item) => price += item.quantity * item.price);
      return price;
    } else {
      return price;
    }
  }

  //edit quantity
  void editQuantity(String id, double quantity) {
    _items.forEach((element) {
      if (element.id == id) {
        element.quantity += quantity;
      }
    });
    notifyListeners();
  }
}
