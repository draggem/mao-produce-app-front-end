import 'package:flutter/material.dart';
import './orderproduct_model.dart';

class OrderModel {
  String id;
  double totalPrice;
  bool isOpen;
  DateTime orderDate;
  List<OrderProduct> products;

  OrderModel({
    @required this.id,
    @required this.totalPrice,
    this.isOpen = true,
    @required this.orderDate,
    @required this.products,
  });
}
