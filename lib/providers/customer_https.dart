import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/customer_model.dart';
import '../models/http_exception.dart';

class CustomerHttps with ChangeNotifier {
  List<CustomerModel> _items = [
    CustomerModel(
        id: 'p1',
        name: 'Vaughn Gigataras',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p2',
        name: 'Vincent Chen',
        email: 'test@test.com',
        phone: 123456789,
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
        if (custName.contains(name)) {
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
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod';
    try {
      final response = await http.get(url);

      final List<CustomerModel> loadedCustomers = [];
      final extractedData = json.decode(response.body);

      if (extractedData == null) {
        return;
      }

      for (var i = 0; i < extractedData.length; i++) {
        loadedCustomers.add(
          CustomerModel(
            id: extractedData[i]['id'],
            name: extractedData[i]['name'],
            email: extractedData[i]['email'],
            address: extractedData[i]['address'],
            phone: extractedData[i]['phone'],
            userDate: DateTime.parse(
              extractedData[i]['createdtimestamp'],
            ),
          ),
        );
      }

      _items = loadedCustomers;
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  //Adding customer
  Future<void> addCustomers(CustomerModel customer) async {
    var url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod';
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': customer.name,
            'email': customer.email,
            'address': customer.address,
            'phone': customer.phone.toString(),
            'createdtimestamp': DateTime.now().toString(),
          },
        ),
      );

      final custId = response.body;

      print(custId);

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
      throw error;
    }
  }

  //Delete a customer
  Future<void> deleteCustomer(String id) async {
    final url =
        'https://ddjevsdgb8.execute-api.ap-southeast-2.amazonaws.com/Prod/$id';
    final existingCustomerIndex =
        _items.indexWhere((customer) => customer.id == id);
    var existingCustomer = _items[existingCustomerIndex];
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingCustomerIndex, existingCustomer);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingCustomer = null;
  }
}
