import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class AuthenticationScreen extends StatelessWidget {
  Future<String> _submit(LoginData data) async {
    print(data);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      logo: 'assets/img/maoproduceLogo.png',
      onLogin: _submit,
      onSignup: _submit,
      // onSubmitAnimationCompleted: (_) {},
      onRecoverPassword: (_) => Future(null),
    );
  }
}
