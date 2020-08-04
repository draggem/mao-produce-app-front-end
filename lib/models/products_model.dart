import 'package:flutter/material.dart';

import './base_product_model.dart';

class ProductsModel extends BaseProductModel {
  String url;

  ProductsModel({
    id,
    price,
    title,
    @required this.url,
  }) : super(
          id: id,
          price: price,
          title: title,
        );
}
