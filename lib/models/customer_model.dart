import 'package:flutter/material.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final int phone;
  final String address;

  CustomerModel({
    @required this.id,
    @required this.name,
    @required this.email,
    this.phone,
    this.address,
  });
}
