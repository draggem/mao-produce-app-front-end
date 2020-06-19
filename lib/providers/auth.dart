import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
//User Authentication Function
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    //API URL link
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyABYrOo3eFNpvUEk56Uf6awqDbmlgYKdhs';
    try {
      //sends post request for login or registration
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);
      print(responseData);

      //checks if there are errors from server e.g("INVALID_EMAIL")
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  //sign in function
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signup');
  }
}
