import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/signaturePad.dart';

class SignatureScreen extends StatefulWidget {
  static const routeName = '/signature';

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool get scrollTest => false;

  @override
  Widget build(BuildContext context) {
    //Force screen to be landscape
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    //Hides the top status bar for androids.
    SystemChrome.setEnabledSystemUIOverlays([]);

    //return the SignaturePad widget
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: new SignaturePad(),
    );
  }
}
