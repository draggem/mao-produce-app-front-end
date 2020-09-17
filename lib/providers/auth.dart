import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  //Variables you acquire when logging in
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  //setting the getters
  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

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

      //checks if there are errors from server e.g("INVALID_EMAIL") and throws it to send to front end
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      //store user id and user current token in variable
      //also calclulate how much time left for the token to expire
      _token = responseData['idToken'];
      _userId = responseData['[localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      //once logged in, start timer for token expiry
      _autoLogout();
      notifyListeners();
      //define phone memory and the data you want to store inside it
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String()
        },
      );

      //store the data inside the phone
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  //registration function
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  //login function
  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  //Logout function
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  //function that Logs in straightaway if user decides to close the app
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    //checks if phone has the user token stored inside
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    //checks if expiry date is expired
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  //logs out automatically if current user token is expired
  //this function is also used to start timer for token once logged in
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
