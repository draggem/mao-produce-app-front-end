import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../models/order_product_model.dart';
import '../models/order_all_model.dart';

class OrderHttps with ChangeNotifier {
  List<OrderAllModel> _items = [
    // OrderModel(
    //   id: 'p1',
    //   totalPrice: 36.00,
    //   isOpen: true,
    //   orderDate: DateTime.now(),
    //   products: [
    //     OrderProductModel(
    //       id: 'gago',
    //       price: 12.00,
    //       title: 'VegeTales',
    //       quantity: 3.00,
    //     )
    //   ],
    // ),
  ];

  List<OrderAllModel> get items {
    return [..._items];
  }

//function that finds orders by id
  OrderAllModel findById(String id) {
    return _items.firstWhere((order) => order.id == id);
  }

//function to find name for search bars
  List<OrderAllModel> findByName(String name) {
    final List<OrderAllModel> orderList = [];
    _items.forEach(
      (order) {
        String orderId = order.id;
        if (name.contains(orderId)) {
          orderList.add(
            OrderAllModel(
              custId: order.custId,
              custName: order.custName,
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

//get order http  per customer request/response
  Future<void> fetchAndSetOrder(String custId, bool isOpen) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders/$custId?isOpen=$isOpen';

    try {
      final response = await http.get(url);

      final List<OrderAllModel> loadedOrders = [];
      final extractedData = json.decode(response.body);

      if (response.statusCode == 404) {
        print('no order ${extractedData['message']}');
        if (extractedData['message'] == 'ORDER_IS_EMPTY') {
          _items = [];
          return null;
        }
      }

      if (extractedData == null) {
        _items = [];
        return;
      }

      for (var i = 0; i < extractedData.length; i++) {
        if (extractedData[i]['id'] != null) {
          loadedOrders.add(
            OrderAllModel(
              id: extractedData[i]['id'],
              orderDate: DateTime.parse(extractedData[i]['datetime']),
              totalPrice: double.parse(extractedData[i]['totalprice']),
              isOpen: (extractedData[i]['isopen']),
              products: (extractedData[i]['products'] as List<dynamic>)
                  .map(
                    (item) => OrderProductModel(
                      id: item['id'],
                      quantity: double.parse(item['quantity']),
                      price: double.parse(item['price']),
                      title: item['title'],
                    ),
                  )
                  .toList(),
            ),
          );
        }
      }

      _items = loadedOrders;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

//get all order http request/response
  Future<void> fetchAndSetAllOrder(bool isOpen) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders?isOpen=$isOpen';

    try {
      final response = await http.get(url);
      print(response.body);
      final List<OrderAllModel> loadedOrders = [];
      final extractedData = json.decode(response.body);

      if (response.statusCode == 404) {
        print('no order ${extractedData['message']}');
        if (extractedData['message'] == 'ORDER_IS_EMPTY') {
          _items = [];
          return null;
        }
      }

      if (extractedData == null) {
        _items = [];
        return;
      }

      for (var i = 0; i < extractedData.length; i++) {
        if (extractedData[i]['id'] != null) {
          loadedOrders.add(
            OrderAllModel(
              custId: extractedData[i]['customerid'],
              custName: extractedData[i]['customername'],
              id: extractedData[i]['id'],
              orderDate: DateTime.parse(extractedData[i]['datetime']),
              totalPrice: double.parse(extractedData[i]['totalprice']),
              isOpen: (extractedData[i]['isopen']),
              products: (extractedData[i]['products'] as List<dynamic>)
                  .map(
                    (item) => OrderProductModel(
                      id: item['id'],
                      quantity: double.parse(item['quantity']),
                      price: double.parse(item['price']),
                      title: item['title'],
                    ),
                  )
                  .toList(),
            ),
          );
        }
      }

      _items = loadedOrders;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
