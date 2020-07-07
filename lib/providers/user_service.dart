import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_cognito.dart';

import './storage.dart';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _identityPoolId = 'ap-southeast-2:546acadb-99c7-485d-b8d4-952d7f1b875c';

class UserService with ChangeNotifier {
  //Variables required before logging in.
  final CognitoUserPool _userPool;
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  CognitoCredentials credentials;
  //Variables you acquire when logging in.
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  UserService(this._userPool);

  //setting the getters
  bool get isAuth {
    return _token != null;
  }

  /// Initiate user session from local storage if present
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = Storage(prefs);
    _userPool.storage = storage;

    _cognitoUser = await _userPool.getCurrentUser();
    if (_cognitoUser == null) {
      return false;
    }
    _session = await _cognitoUser.getSession();
    return _session.isValid();
  }

  /// Get existing user from session with his/her attributes
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

  /// Retrieve user credentials -- for use with other AWS services
  Future<CognitoCredentials> getCredentials() async {
    if (_cognitoUser == null || _session == null) {
      return null;
    }
    credentials = CognitoCredentials(_identityPoolId, _userPool);
    await credentials.getAwsCredentials(_session.getIdToken().getJwtToken());
    return credentials;
  }

  /// Login user
  Future<User> login(String email, String password) async {
    //Needed
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
      _token = _session.getAccessToken().getJwtToken();
      _userId = _cognitoUser.getUsername();
      int tokenExpiry = _session.getAccessToken().getExpiration();
      //Convert expiry to DateTime
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: tokenExpiry,
        ),
      );
      //set isConfirmed
      isConfirmed = true;
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
      print("you are logged in");
    } on CognitoClientException catch (e) {
      if (e.code == 'UserNotConfirmedException') {
        isConfirmed = false;
      } else {
        rethrow;
      }
      throw e;
    }

    if (!_session.isValid()) {
      return null;
    }

    final attributes = await _cognitoUser.getUserAttributes();
    final user = User.fromUserAttributes(attributes);
    user.confirmed = isConfirmed;
    user.hasAccess = true;

    return user;
  }

  /// Confirm user's account with confirmation code sent to email
  Future<bool> confirmAccount(String email, String confirmationCode) async {
    _cognitoUser = CognitoUser(email, _userPool, storage: _userPool.storage);

    return await _cognitoUser.confirmRegistration(confirmationCode);
  }

  /// Resend confirmation code to user's email
  Future<void> resendConfirmationCode(String email) async {
    _cognitoUser = CognitoUser(email, _userPool, storage: _userPool.storage);
    await _cognitoUser.resendConfirmationCode();
  }

  /// Check if user's current session is valid
  Future<bool> checkAuthenticated() async {
    if (_cognitoUser == null || _session == null) {
      return false;
    }
    return _session.isValid();
  }

  /// Sign upuser
  Future<User> signUp(String email, String password) async {
    try {
      print('sign up method');

      CognitoUserPoolData data;
      data = await _userPool.signUp(email, password);

      final user = User();
      user.email = email;
      user.confirmed = data.userConfirmed;

      print(data.runtimeType.toString());

      return user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      _token = null;
      _authTimer = null;
      _expiryDate = null;
      _userId = null;
      if (credentials != null) {
        await credentials.resetAwsCredentials();
      }
      if (_authTimer != null) {
        _authTimer.cancel();
        _authTimer = null;
      }
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      if (_cognitoUser != null) {
        print("oten");
        return _cognitoUser.signOut();
      }
    } catch (e) {
      print("you have a problem at signout func: ${e.toString()}");
      throw e.toString();
    }
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
    _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
  }
}
