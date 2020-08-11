import 'package:flutter/material.dart';

import '../models/order_product_model.dart';

class AddingProductOrder with ChangeNotifier {
  List<OrderProductModel> _items = [
    OrderProductModel(
      quantity: 3.0,
      id: 'p2',
      price: 20.0,
      title: 'VegeOten',
    )
  ];

  List<OrderProductModel> get items {
    return [..._items];
  }

//function th
  void addOrder(OrderProductModel order) {
    items.add(order);
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
}
