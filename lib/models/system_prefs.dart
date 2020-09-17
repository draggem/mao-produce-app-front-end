import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SystemPrefs {
  static getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.decode(prefs.getString('userData'));
    final userToken = userData['token'];
    print(userData['token']);
    return userToken;
  }
}
