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
    CustomerModel(
        id: 'p3',
        name: 'George Somoso',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p4',
        name: 'Hsin-Chen Tsai',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p5',
        name: 'Raj',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p6',
        name: 'Boss Lady',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p7',
        name: 'Jan Lorenz Loresco',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p8',
        name: 'Faith',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
    CustomerModel(
        id: 'p9',
        name: 'Orange House',
        email: 'test@test.com',
        phone: 123456789,
        address: '295 Blenheim Rd, Upper Riccarton, Christchurch'),
  ];

  List<CustomerModel> get items {
    return [..._items];
  }

  //function that finds customers by id
  CustomerModel findById(String id) {
    return _items.firstWhere((customer) => customer.id == id);
  }

  //Customer Get Response
  Future<void> fetchAndSetCustomers(
      [bool filterByUser = false, String customerId]) async {}
}
