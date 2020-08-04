import 'package:flutter/material.dart';

class BaseProductModel {
  String id;
  String title;
  double price;

  BaseProductModel({
    @required this.id,
    @required this.title,
    @required this.price,
  });
}
