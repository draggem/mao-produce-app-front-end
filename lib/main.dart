import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './models/secret.dart';

import './providers/auth.dart';
import './providers/user_service.dart';
import './providers/customer_https.dart';
import './providers/recent_searches.dart';
import './providers/product_https.dart';

import './screens/auth_screen.dart';
import './screens/menu_screen.dart';
import './screens/splash_screen.dart';
import './screens/customer_screen.dart';
import './screens/searched_item_screen.dart';
import './screens/edit_customer_screen.dart';
import './screens/product_screen.dart';
import './screens/edit_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: CustomerHttps(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: UserService(Secret.userPool),
        ),
        ChangeNotifierProvider.value(
          value: RecentSearches(),
        ),
        ChangeNotifierProvider.value(
          value: ProductHttps(),
        )
      ],
      child: Consumer<UserService>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Mao Produce',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(3, 153, 18, 1),
            accentColor: Color.fromRGBO(3, 153, 18, 1),
            textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white, fontSize: 20),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          home: auth.isAuth
              ? MenuScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            MenuScreen.routeName: (ctx) => MenuScreen(),
            CustomerScreen.routeName: (ctx) => CustomerScreen(),
            SearchedItemScreen.routeName: (ctx) => SearchedItemScreen(),
            EditCustomerScreen.routeName: (ctx) => EditCustomerScreen(),
            ProductScreen.routeName: (ctx) => ProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
