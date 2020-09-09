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
        price: 12.00,
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
      final dataLength = extractedData.length;

      if (extractedData == null) {
        return;
      }

      for (var i = 0; i < dataLength; i++) {
        if (extractedData[i]['title'] != null ||
            extractedData[i]['price'] != null) {
//grab the img Url
          String imgUrl = extractedData[i]['imageurl'];

          if (imgUrl != null) {
            //pattern to check expression
            var urlPattern =
                r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
            var match =
                new RegExp(urlPattern, caseSensitive: false).hasMatch(imgUrl);

            //checks if pattern matches or if it actually is a valid link
            if (match == true) {
              //check img link response
              final imgUrlResponse = await http.head(imgUrl);

              if (imgUrlResponse.statusCode != 200) {
                imgUrl = '';
              }
            } else {
              imgUrl = '';
            }
          } else {
            imgUrl = '';
          }

          //Validate the image url link

          loadedProducts.add(
            ProductsModel(
                id: extractedData[i]['id'],
                title: extractedData[i]['title'],
                price: double.parse(extractedData[i]['price']),
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

  //Add Products
  Future<void> addProduct(ProductsModel product) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Products';

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'Title': product.title,
            'Price': product.price.toStringAsFixed(2),
            'ImageUrl': product.url
          },
        ),
      );

      final prodId = response.body;

      final newProduct = ProductsModel(
        id: prodId,
        title: product.title,
        price: product.price,
        url: product.url,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  //Delete a Product
  Future<void> deleteProduct(String id) async {
    final url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Products/$id';
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  //Editing a Product
  Future<void> updateProduct(String id, ProductsModel newProduct) async {
    try {
      final productIndex = _items.indexWhere((prod) => prod.id == id);

      if (productIndex >= 0) {
        final url =
            'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Products/$id';

        final response = await http.patch(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              'Id': newProduct.id,
              'Title': newProduct.title,
              'Price': newProduct.price.toStringAsFixed(2),
              'ImageUrl': newProduct.url,
            }));
        print(json.decode(response.body));
        _items[productIndex] = newProduct;
      }
    } catch (e) {
      print(e);
      throw (e);
    }
  }
}
