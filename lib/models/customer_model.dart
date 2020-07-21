import 'package:flutter/material.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  DateTime userDate;

  CustomerModel({
    @required this.id,
    @required this.name,
    @required this.email,
    this.phone,
    this.address,
    this.userDate,
  });
}
