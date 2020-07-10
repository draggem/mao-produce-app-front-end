import 'package:flutter/material.dart';

//the model to make the options in the menu

class MenuOptions {
  final String routeName;
  final String title;
  final Color color;
  final IconData icon;

  const MenuOptions({
    @required this.routeName,
    @required this.title,
    @required this.icon,
    this.color = Colors.orange,
  });
}
