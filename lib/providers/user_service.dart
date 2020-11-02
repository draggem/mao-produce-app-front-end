import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_cognito.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './storage.dart';

class UserService with ChangeNotifier {
  //********Variables required before logging in.
  CognitoUserPool _userPool;
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  UserService(this._userPool);
  CognitoCredentials credentials;
  //****** */
  Timer _refresherTime;

  //******This method is auto run when app is initialized and user has signed in */
  //***It then runs a timer that will renew Id Token automatically */
  void refresher() {
    try {
      if (_refresherTime != null) {
        _refresherTime.cancel();
      }
      final timeToExpiry = (_session.getIdToken().getExpiration() -
          (DateTime.now().millisecondsSinceEpoch / 1000).round());
      _refresherTime = Timer(Duration(seconds: timeToExpiry), init);
    } catch (e) {}
  }

  ///*** */ Initiate user session from local storage if present
  ///***THIS IS THE AUTO SIGN IN METHOD */
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = Storage(prefs);
    _userPool.storage = storage;

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      prefs.clear();
      return false;
    }
    _session = await _cognitoUser.getSession();

    //ADDED ANOTHER SharedPrefs called userData where the idToken for api request
    final userData = json.encode({
      'token': _session.getIdToken().getJwtToken(),
    });
    prefs.setString('userData', userData);
    notifyListeners();
    refresher();
    return _session.isValid();
  }
  //*********** */

  bool get isAuth {
    return _session != null;
  }

  ///******Get existing user from session with his/her attributes
  Future<User> getCurrentUser() async {
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    if (!_session.isValid()) {
      return null;
    }
    final attributes = await _cognitoUser.getUserAttributes();
    if (attributes == null) {
      return null;
    }
    final user = User.fromUserAttributes(attributes);
    user.hasAccess = true;
    return user;
  }
  //************************** */

  ///************Login user
  Future<User> login(String email, String password) async {
    _cognitoUser = CognitoUser(
      email,
      _userPool,
      storage: _userPool.storage,
    );

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    bool isConfirmed;
    try {
      _session = await _cognitoUser.authenticateUser(authDetails);
      isConfirmed = true;
    } on CognitoClientException catch (e) {
      if (e.code == 'UserNotConfirmedException') {
        isConfirmed = false;
      } else {
        rethrow;
      }
    }

    if (!_session.isValid()) {
      return null;
    }

    final attributes = await _cognitoUser.getUserAttributes();
    final user = User.fromUserAttributes(attributes);
    user.confirmed = isConfirmed;
    user.hasAccess = true;
    notifyListeners();
    return user;
  }
  //************* */

  ///******Signup user
  Future<User> signUp(String email, String password) async {
    try {
      CognitoUserPoolData data;
      data = await _userPool.signUp(email, password);

      final user = User();
      user.email = email;
      user.confirmed = data.userConfirmed;

      return user;
    } catch (e) {
      throw e;
    }
  }
  //********* */

  //**************** */
  Future<void> signOut() async {
    if (credentials != null) {
      await credentials.resetAwsCredentials();
    }
    if (_cognitoUser != null) {
      _cognitoUser.signOut();
      _cognitoUser = null;
    }
    if (_session != null) {
      _session = null;
    }
    notifyListeners();
  }
  //***************** */

  //logs out automatically if current user token is expired
  //this function is also used to start timer for token once logged in
  // void _autoLogout() {
  //   try {
  //     if (_authTimer != null) {
  //       _authTimer.cancel();
  //     }
  //     final timeToExpiry = _session.getClockDrift();
  //     print(timeToExpiry);
  //     _authTimer = Timer(Duration(seconds: timeToExpiry), init);
  //   } catch (e) {}
  // }
}
