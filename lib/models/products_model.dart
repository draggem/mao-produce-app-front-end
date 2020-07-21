import 'package:flutter/material.dart';

class ProductsModel {
  String id;
  double price;
  String title;
  String url;

  ProductsModel({
    @required this.id,
    @required this.price,
    @required this.title,
    this.url,
  });
}
