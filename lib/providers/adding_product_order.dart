import 'package:flutter/material.dart';

import '../models/order_product_model.dart';

class AddingProductOrder with ChangeNotifier {
  Map<String, OrderProductModel> _items = {};

  Map<String, OrderProductModel> get items {
    return {..._items};
  }

//function to add product
  void addOrder(OrderProductModel order) {
    //checks if products is in the list or not
    if (_items.containsKey(order.id)) {
      _items.update(
          order.id,
          (existingProduct) => OrderProductModel(
                id: existingProduct.id,
                price: existingProduct.price += order.price,
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
    print(_items);
    notifyListeners();
  }

//function to remove product
  void removeProduct(String id) {
    _items.remove(id);

    notifyListeners();
    print(items);
  }

//calculates the total price
  double totalPrice() {
    double price = 0;

    _items.forEach(
      (key, element) => {price += element.quantity * element.price},
    );

    return price;
  }
}
