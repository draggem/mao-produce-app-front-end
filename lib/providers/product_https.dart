import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/products_model.dart';
import '../models/http_exception.dart';

class ProductHttps with ChangeNotifier {
  List<ProductsModel> _items = [
    ProductsModel(
        id: 'gago',
        title: 'VegeTales',
        price: 12,
        url: 'https://picsum.photos/id/237/200/300'),
  ];

  List<ProductsModel> get items {
    return [..._items];
  }

  //function that finds products by id
  ProductsModel findById(String id) {
    return _items.firstWhere((products) => products.id == id);
  }

  //function to find name for search bars
  List<ProductsModel> findByName(String name) {
    final List<ProductsModel> productsList = [];
    _items.forEach(
      (product) {
        String prodTitle = product.title;
        if (name.contains(prodTitle)) {
          print('oten');
          productsList.add(
            ProductsModel(
                title: prodTitle,
                id: product.id,
                price: product.price,
                url: product.url),
          );
        }
      },
    );
    return productsList;
  }

  //Products get response
  Future<void> fetchAndSetProducts() async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Products';

    try {
      final response = await http.get(url);

      final List<ProductsModel> loadedProducts = [];
      final extractedData = json.decode(response.body);

      if (extractedData == null) {
        return;
      }

      for (var i = 0; i < extractedData.length; i++) {
        if (extractedData[i]['Title'] != null ||
            extractedData[i]['Price'] != null) {
          //checks if the Image Url provided starts with 'http://'
          String imgUrl = extractedData[i]['ImageUrl'];
          if (!imgUrl.startsWith('http://')) {
            imgUrl = 'http://$imgUrl';
          }

          final imgUrlResponse = await http.head(imgUrl);

          //Validate the image url link
          if (imgUrlResponse.statusCode != 200) {
            imgUrl = '';
          }

          loadedProducts.add(
            ProductsModel(
                id: extractedData[i]['Id'],
                title: extractedData[i]['Title'],
                price: double.parse(extractedData[i]['Price']),
                url: imgUrl),
          );
        }
      }

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }
}
