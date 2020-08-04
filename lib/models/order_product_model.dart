import 'package:flutter/material.dart';
import 'package:mao_produce/models/base_product_model.dart';

import './base_product_model.dart';

class OrderProductModel extends BaseProductModel {
  double quantity;

  OrderProductModel({id, price, title, @required this.quantity})
      : super(
          id: id,
          price: price,
          title: title,
        );
}
