import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../models/orderproduct_model.dart';

class OrderHttps with ChangeNotifier {
  List<OrderModel> _items = [
    OrderModel(
      id: 'p1',
      totalPrice: 36,
      isOpen: true,
      orderDate: DateTime.now(),
      products: [
        OrderProduct(
          id: 'gago',
          price: 12,
          title: 'VegeTales',
          quantity: 3,
        )
      ],
    ),
  ];

  List<OrderModel> get items {
    return [..._items];
  }

//function that finds orders by id
  OrderModel findById(String id) {
    return _items.firstWhere((order) => order.id == id);
  }

//function to find name for search bars
  List<OrderModel> findByName(String name) {
    final List<OrderModel> orderList = [];
    _items.forEach(
      (order) {
        String orderId = order.id;
        if (name.contains(orderId)) {
          orderList.add(
            OrderModel(
              id: orderId,
              totalPrice: order.totalPrice,
              isOpen: order.isOpen,
              orderDate: order.orderDate,
              products: order.products,
            ),
          );
        }
      },
    );
    return orderList;
  }
}

//get order http request/response
Future<void> fetchAndSetProducts(String id, bool isOpen) async {
  var url =
      'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders/$id?isOpen=$isOpen';

  try {
    // final response = await http.get(url);

    // final List<OrderModel> loadedOrders = [];
    // final extractedData = json.decode(response.body);

    // if (extractedData == null) {
    //   return;
    // }

    // print(extractedData);
    // for (var i = 0; i < extractedData.length; i++) {}
  } catch (e) {}
}
