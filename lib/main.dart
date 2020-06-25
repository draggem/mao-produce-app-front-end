import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';

import './screens/auth_screen.dart';
import './screens/menu_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
              title: 'Mao Produce',
              theme: ThemeData(
                primarySwatch: Colors.green,
                accentColor: Colors.greenAccent,
                textTheme: TextTheme(
                  headline6: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              home: AuthScreen(),
              routes: {
                MenuScreen.routeName: (ctx) => MenuScreen(),
              }),
        ));
  }
}
