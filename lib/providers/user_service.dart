import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user_cognito.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService with ChangeNotifier {
  //Variables required before logging in.
  final CognitoUserPool _userPool;
  CognitoUser _cognitoUser;
  CognitoUserSession _session;
  CognitoCredentials credentials;

  //Variables you acquire when logging in.
  var _refreshToken;
  var _accessToken;
  String _idToken;

  ///DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  UserService(this._userPool);

  bool get isAuth {
    return _idToken != null;
  }

  /// Login user
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
      _idToken = _session.getIdToken().getJwtToken();
      _refreshToken = _session.getRefreshToken().getToken();
      _accessToken = _session.getAccessToken().getJwtToken();
      _userId = _cognitoUser.getUsername();
      ////var tokenExpiry = _session.getIdToken().getExpiration();
      ////var date = new DateTime.fromMillisecondsSinceEpoch(tokenExpiry * 1000);
      //Convert expiry to DateTime
      ////_expiryDate = date;
      //set isConfirmed
      isConfirmed = true;
      //once logged in, start timer for token expiry
      _autoLogout();
      notifyListeners();

      if (!_session.isValid()) {
        return null;
      }

      //define phone memory and the data you want to store inside it
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'userId': _userId,
          'token': _idToken,
          'refreshToken': _refreshToken,
          'accessToken': _accessToken,
          ////'expiryDate': _expiryDate.toIso8601String()
        },
      );
      //store the data inside the phone
      prefs.setString('userData', userData);

      //This is storage memory number 2
      final attributes = await _cognitoUser.getUserAttributes();
      final user = User.fromUserAttributes(attributes);
      user.confirmed = isConfirmed;
      user.hasAccess = true;
      return user;
    } on CognitoClientException catch (e) {
      if (e.code == 'UserNotConfirmedException') {
        isConfirmed = false;
      } else {
        rethrow;
      }
      throw e;
    }
  }

  /// Sign upuser
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

  Future<void> signOut() async {
    try {
      //_cognitoUser.signOut();
      _accessToken = null;
      _refreshToken = null;
      _idToken = null;
      _authTimer = null;
      /////_expiryDate = null;
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
        return _cognitoUser.signOut();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  //function that Logs in straightaway if user decides to close the app
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    final refreshToken =
        new CognitoRefreshToken(extractedUserData['refreshToken']);
    final idToken = new CognitoIdToken(extractedUserData['token']);
    final accessToken =
        new CognitoAccessToken(extractedUserData['accessToken']);
    _session = new CognitoUserSession(idToken, accessToken,
        refreshToken: refreshToken);
    try {
      if (!_session.isValid()) {
        _session = await _cognitoUser.refreshSession(refreshToken);
        final userData = json.encode(
          {
            'userId': extractedUserData['userId'],
            'token': _session.getIdToken().getJwtToken(),
            'refreshToken': _session.getRefreshToken().getToken(),
            'accessToken': _session.getAccessToken().getJwtToken(),
          },
        );
        //store the data inside the phone
        prefs.setString('userData', userData);
        _idToken = _session.getIdToken().getJwtToken();
        _refreshToken = _session.getRefreshToken().getToken();
        _accessToken = _session.getAccessToken().getJwtToken();
        _idToken = extractedUserData['token'];
        notifyListeners();
        return true;
      } else {
        _idToken = extractedUserData['token'];
        notifyListeners();
        return true;
      }
    } catch (e) {
      notifyListeners();
      _autoLogout();
      print(e.toString());
      return false;
    }
  }

  //logs out automatically if current user token is expired
  //this function is also used to start timer for token once logged in
  void _autoLogout() {
    try {
      if (_authTimer != null) {
        _authTimer.cancel();
      }
      //final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: 86400), tryAutoLogin);
    } catch (e) {}
  }
}
