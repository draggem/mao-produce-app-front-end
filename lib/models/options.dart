import 'package:flutter/material.dart';
import 'package:mao_produce/screens/product_screen.dart';

import '../screens/customer_screen.dart';
import '../screens/order_screen.dart';

import './custom_icons_icons.dart';

import 'menu_options.dart';

//Data for the options on the menu
const OPTIONS = const [
  MenuOptions(
    routeName: CustomerScreen.routeName,
    title: 'Customers',
    icon: Icons.people,
    color: Color.fromRGBO(3, 153, 18, 1),
  ),
  MenuOptions(
    routeName: OrderScreen.routeName,
    title: 'Orders',
    icon: Icons.assignment,
    color: Colors.blue,
  ),
  MenuOptions(
    routeName: ProductScreen.routeName,
    title: 'Vegetables',
    icon: CustomIcons.leaf,
    color: Colors.orange,
  ),
];

//HardCoded data for front end testing
const CUSTOMERS = const [
  'George Somoso',
  'Vincent Chen',
  'Vaughn Gigataras',
  'Hsin-Chen Tsai',
  'Raj',
  'Eminem Night Skies',
  'Mama Chen',
  'Boss Lady',
  'Cash Guy',
  'Favourite Samoan Customer',
  'The Gay',
  'Bruno Mars',
  'Cardi Bra',
  'Jan Lorenz Loresco',
  'Faith',
  'Patience Ngara',
  'Takunda Ngara',
  'Clive Ngara',
  'Pastor Mebzar',
  'Alfie Alujado',
  'Orange House',
  'Bible Black',
  'Namewee'
];
