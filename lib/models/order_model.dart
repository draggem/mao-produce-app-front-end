import 'package:flutter/material.dart';
import './order_product_model.dart';

class OrderModel {
  String id;
  double totalPrice;
  bool isOpen;
  DateTime orderDate;
  List<OrderProductModel> products;

  OrderModel({
    @required this.id,
    @required this.totalPrice,
    this.isOpen = true,
    @required this.orderDate,
    @required this.products,
  });
}
