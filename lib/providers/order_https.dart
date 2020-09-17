import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_product_model.dart';
import '../models/order_all_model.dart';
import '../models/http_exception.dart';

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

//function to find query for search bars
  List<OrderAllModel> findByQuery(String query) {
    final List<OrderAllModel> orderList = [];
    _items.forEach(
      (order) {
        String orderId = order.id;
        String orderCustName = order.custName == null ? query : order.custName;
        String orderDate =
            DateFormat('dd/MM/yyyy').format(order.orderDate).toString();
        String totalPrice = order.totalPrice.toStringAsFixed(2);
        if (query.contains(orderId) &&
            query.contains(orderCustName) &&
            query.contains(orderDate) &&
            query.contains(totalPrice)) {
          orderList.add(
            OrderAllModel(
              custId: order.custId,
              custName: order.custName == null ? 'gay' : order.custName,
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
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];

    try {
      _items = [];
      final response = await http.get(url, headers: {
        'Authorization': userToken,
        'Content-Type': 'application/json'
      });

      final List<OrderAllModel> loadedOrders = [];
      final extractedData = json.decode(response.body);

      if (response.statusCode == 404) {
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
                custName: extractedData[i]['customername'],
                custId: extractedData[i]['customerid'],
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
                signature: {
                  'signature':
                      extractedData[i]['signature']['signature'] == null
                          ? null
                          : extractedData[i]['signature']['signature'],
                  'signee': extractedData[i]['signature']['signee'] == null
                      ? null
                      : extractedData[i]['signature']['signee']
                }),
          );
        }
      }
      _items = loadedOrders;
      notifyListeners();
    } catch (e) {
      throw "We could not connect you to the server. Please check your internet connection.";
    }
  }

//get all order http request/response
  Future<void> fetchAndSetAllOrder(bool isOpen) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders?isOpen=$isOpen';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];

    try {
      final response = await http.get(url, headers: {
        'Authorization': userToken,
        'Content-Type': 'application/json'
      });
      final List<OrderAllModel> loadedOrders = [];
      final extractedData = json.decode(response.body);

      if (response.statusCode == 404) {
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
                signature: {
                  'signature': extractedData[i]['signature']['signature'],
                  'signee': extractedData[i]['signature']['signee']
                }),
          );
        }
      }

      _items = loadedOrders;
      notifyListeners();
    } catch (e) {
      throw "There was something wrong. Please check your internet connection";
    }
  }

  //Email Function for adding orders
  Future<void> sendEmail(
      OrderAllModel order, var signature, String signee, bool isEditing) async {
    bool editing = isEditing;
    var orderIndex;
    var response;
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Send/${order.custId}';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    bool orderStatus = signature == null ? order.isOpen : false;

    //check if it is editing
    if (editing || order.id != null) {
      url += '?orderId=${order.id}';
      orderIndex = _items.indexWhere((prod) => prod.id == order.id);
      if (orderIndex >= 0) {
        editing = false;
      }
    }

    try {
      response = await http.post(url,
          headers: {
            'Authorization': userToken,
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'customerid': order.custId,
            'customername': order.custName,
            'id': order.id,
            'datetime': order.orderDate.toString(),
            'totalprice': order.totalPrice,
            'isopen': orderStatus.toString(),
            'products': order.products
                .map((item) => {
                      'id': item.id,
                      'quantity': item.quantity,
                      'price': item.price,
                      'title': item.title,
                    })
                .toList(),
            'signature': {
              'signature': signature == null || signee == null
                  ? ''
                  : signature.toString(),
              'signee': signee == null || signature == null ? '' : signee,
            }
          }));
    } catch (e) {
      throw "There was something wrong. Please check your internet connection";
    }
    if (editing) {
      _items[orderIndex] = order;
    } else {
      //add order if it is not editing
      final extractedResponse = json.decode(response.body);
      final orderId = extractedResponse['orderId'];
      final newOrder = OrderAllModel(
        id: orderId,
        custId: order.custId,
        custName: order.custName,
        isOpen: orderStatus,
        orderDate: DateTime.now(),
        products: order.products,
        totalPrice: order.totalPrice,
      );
      _items.add(newOrder);
    }

    notifyListeners();
  }

  //update order function
  Future<void> updateOrder(
      OrderAllModel order, var signature, String signee) async {
    bool orderStatus = signature == null ? order.isOpen : false;
    try {
      final orderIndex = _items.indexWhere((prod) => prod.id == order.id);

      if (orderIndex >= 0) {
        var url =
            'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders/${order.custId}?orderId=${order.id}';
        final prefs = await SharedPreferences.getInstance();
        final userData = json.decode(prefs.getString('userData'));
        var userToken = userData['token'];
        final response = await http.patch(url,
            headers: {
              'Authorization': userToken,
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'customerid': order.custId,
              'customername': order.custName,
              'id': order.id,
              'datetime': order.orderDate.toString(),
              'totalprice': order.totalPrice,
              'isopen': orderStatus.toString(),
              'products': order.products
                  .map((item) => {
                        'id': item.id,
                        'quantity': item.quantity,
                        'price': item.price,
                        'title': item.title,
                      })
                  .toList(),
              'signature': {
                'signature': signature,
                'signee': signee,
              }
            }));

        _items[orderIndex] = order;
        notifyListeners();
      } else {}
    } catch (e) {
      throw "There was something wrong. Please check your internet connection";
    }
  }

  //add order function
  Future<void> addOrder(
      OrderAllModel order, var signature, String signee) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders/${order.custId}';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    //check if it has signature. If it does, make it close else open
    bool orderStatus = signature == null ? order.isOpen : false;

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': userToken,
          'Content-Type': 'application/json'
        },
        body: json.encode(
          {
            'customerid': order.custId,
            'customername': order.custName,
            'id': order.id.toString(),
            'orderData': DateTime.now().toString(),
            'totalprice': order.totalPrice.toString(),
            'isopen': orderStatus.toString(),
            'products': order.products
                .map(
                  (product) => {
                    'Id': product.id,
                    'Price': product.price,
                    'Quantity': product.quantity,
                    'Title': product.title,
                  },
                )
                .toList(),
            'signature': {
              'signee': signee == null || signature == null ? '' : signee,
              'signature': signature == null || signee == null
                  ? ''
                  : signature.toString(),
            }
          },
        ),
      );

      final extractedResponse = json.decode(response.body);
      final orderId = extractedResponse['orderId'];

      final newOrder = OrderAllModel(
        id: orderId,
        custId: order.custId,
        custName: order.custName,
        isOpen: orderStatus,
        orderDate: DateTime.now(),
        products: order.products,
        totalPrice: order.totalPrice,
      );
      _items.add(newOrder);
      notifyListeners();
    } catch (error) {
      throw "There was something wrong. Please check your internet connection";
    }
  }

  //remove order
  Future<void> deleteOrder(String id, String custId) async {
    final url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Orders/$custId?orderId=$id';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    final existingOrderIndex = _items.indexWhere((product) => product.id == id);
    var existingOrder = _items[existingOrderIndex];
    notifyListeners();

    final response = await http.delete(url, headers: {
      'Authorization': userToken,
      'Content-Type': 'application/json'
    });
    final msg = response.body;
    if (response.statusCode >= 400) {
      _items.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw HttpException('Order could not be deleted');
    }
  }
}
