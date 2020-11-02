import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';
import '../models/http_exception.dart';

class CustomerHttps with ChangeNotifier {
  List<CustomerModel> _items = [
    CustomerModel(
        id: 'p1',
        name: 'Vaughn Gigataras',
        email: 'test@test.com',
        phone: '123456789',
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p2',
        name: 'Vincent Chen',
        email: 'test@test.com',
        phone: '123456789',
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p3',
    //     name: 'George Somoso',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p4',
    //     name: 'Hsin-Chen Tsai',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p5',
    //     name: 'Raj',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p6',
    //     name: 'Boss Lady',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p7',
    //     name: 'Jan Lorenz Loresco',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p8',
    //     name: 'Faith',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p9',
    //     name: 'Orange House',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    // CustomerModel(
    //     id: 'p10',
    //     name: 'Orange House',
    //     email: 'test@test.com',
    //     phone: 123456789,
    //     address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
  ];

  List<CustomerModel> get items {
    return [..._items];
  }

  //function that finds customers by id
  CustomerModel findById(String id) {
    return _items.firstWhere((customer) => customer.id == id);
  }

//function to find name for search bars
  List<CustomerModel> findByName(String name) {
    final List<CustomerModel> customerList = [];
    _items.forEach(
      (customer) {
        String custName = customer.name;
        if (name.contains(custName)) {
          customerList.add(
            CustomerModel(
              name: custName,
              id: customer.id,
              email: customer.email,
            ),
          );
        }
      },
    );
    return customerList;
  }

  //Customer Get Response
  Future<void> fetchAndSetCustomers() async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Customers';
    final prefs = await SharedPreferences.getInstance();
    final userData = await json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    final response = await http.get(url, headers: {
      'Authorization': userToken,
      'Content-Type': 'application/json'
    });

    try {
      final List<CustomerModel> loadedCustomers = [];
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }

      for (var i = 0; i < extractedData.length; i++) {
        if (extractedData[i]['name'] != null) {
          loadedCustomers.add(
            CustomerModel(
              id: extractedData[i]['id'],
              name: extractedData[i]['name'],
              email: extractedData[i]['email'],
              address: extractedData[i]['address'],
              phone: extractedData[i]['phonenumber'],
              userDate: DateTime.parse(
                extractedData[i]['createdtimestamp'],
              ),
            ),
          );
        }
      }

      _items = loadedCustomers;
      notifyListeners();
    } on NoSuchMethodError catch (e) {
      print(e);
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  //Adding customer
  Future<void> addCustomers(CustomerModel customer) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Customers';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': userToken,
          'Content-Type': 'application/json'
        },
        body: json.encode(
          {
            'name': customer.name,
            'email': customer.email,
            'address': customer.address,
            'phonenumber': customer.phone.toString(),
            'createdtimestamp': DateTime.now().toString(),
          },
        ),
      );

      final custId = response.body;

      final newCustomer = CustomerModel(
          id: custId,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          address: customer.address,
          userDate: customer.userDate);
      _items.add(newCustomer);
      notifyListeners();
    } catch (error) {
      throw "There was something wrong. Please check your internet connection";
    }
  }

  //Delete a customer
  Future<void> deleteCustomer(String id) async {
    final url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Customers/$id';
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    var userToken = userData['token'];
    final existingCustomerIndex =
        _items.indexWhere((customer) => customer.id == id);
    var existingCustomer = _items[existingCustomerIndex];
    notifyListeners();

    final response = await http.delete(url, headers: {
      'Authorization': userToken,
      'Content-Type': 'application/json'
    });

    if (response.statusCode >= 400) {
      _items.insert(existingCustomerIndex, existingCustomer);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingCustomer = null;
  }

  //Editing a Customer
  Future<void> updateCustomer(String id, CustomerModel newCustomer) async {
    try {
      final customerIndex = _items.indexWhere((cust) => cust.id == id);

      if (customerIndex >= 0) {
        final url =
            'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/Customers/$id';
        final prefs = await SharedPreferences.getInstance();
        final userData = json.decode(prefs.getString('userData'));
        var userToken = userData['token'];

        final response = await http.patch(url,
            headers: {
              'Authorization': userToken,
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'id': newCustomer.id,
              'name': newCustomer.name,
              'email': newCustomer.email,
              'address': newCustomer.address,
              'phonenumber': newCustomer.phone,
              'createdtimestamp': _items[customerIndex].userDate.toString(),
            }));

        if (response.statusCode != 200) {
          throw HttpException('Unable to update customer.');
        }
        _items[customerIndex] = newCustomer;
      }
    } catch (e) {
      throw "There was something wrong. Please check your internet connection";
    }
  }
}
