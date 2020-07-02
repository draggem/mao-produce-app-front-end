import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../providers/auth.dart';
import '../providers/user_service.dart';

import '../models/http_exception.dart';

enum AuthMode {
  Signup,
  Login
} //names of modes to switch from login or registration

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'passowrd': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

//this function runs before the app is run
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

//function to switch from sign up to login or vice versa
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  //show error pop up
  void _showErrorDialog(String message, bool success) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: success == false ? Text('An Error Occured!') : Text('Success!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (success == true) {
                Navigator.of(ctx).pop();
                _switchAuthMode();
              } else {
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    var success = false;
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        //Log user in

        await Provider.of<UserService>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      } else {
        //Sign user up

        await Provider.of<UserService>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);

        success = true;

        _showErrorDialog(
            'An email has been sent to verify your account', success);
      }
      setState(() {
        _isLoading = false;
      });
    } on CognitoClientException catch (error) {
      var errorMessage = 'Authentication Failed';
      print(error.toString());

      success = false;

      //If statements for every error message backend gives
      //This is the front end receiver for the http_exceptions to display in front end
      if (error.code == 'UsernameExistsException') {
        errorMessage = 'This email has already been taken';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }

      _showErrorDialog(errorMessage, success);
    } catch (error) {
      //error from phone
      const errorMessage =
          'Could not authenticate you. Check your internet conncetion';

      success = false;

      _showErrorDialog(errorMessage, success);
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  //Email field
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    // labelStyle: TextStyle(
                    //     color: _emailFocusNode.hasFocus
                    //         ? Colors.green
                    //         : Colors.white),
                    // enabledBorder: UnderlineInputBorder(
                    //   borderSide: new BorderSide(color: Colors.white),
                    // ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    //checks the form
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  //Password field
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    // labelStyle: TextStyle(
                    //     color: _passFocusNode.hasFocus
                    //         ? Colors.green
                    //         : Colors.white),
                    // enabledBorder: UnderlineInputBorder(
                    //   borderSide: new BorderSide(color: Colors.white),
                    // ),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    //checks the form
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  duration: Duration(milliseconds: 300),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          enabled: _authMode == AuthMode.Signup,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                          //Validator only works if the _authMode is Signup
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                }
                              : null),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                //LOADING INDICATOR IF STATEMENT
                if (_isLoading)
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                  )
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
