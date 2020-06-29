import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth'; //route name to navigat to this screen

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    transformConfig.translate(-10.0);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(40),
                      child: Image.asset('assets/img/maoProduceLeaf.png',
                          width: 70),
                    ),
                  ),
                  AuthCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
