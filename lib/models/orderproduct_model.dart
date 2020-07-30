import 'package:flutter/material.dart';

import './products_model.dart';

class OrderProduct extends ProductsModel {
  double quantity;

  OrderProduct({id, price, title, url, @required this.quantity})
      : super(
          id: id,
          price: price,
          title: title,
          url: url,
        );
}
