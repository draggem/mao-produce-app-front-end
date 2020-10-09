import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/signaturePad.dart';
import '../widgets/scaffold_body.dart';

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
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  bool get scrollTest => false;

  @override
  Widget build(BuildContext context) {
    //Force screen to be landscape
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    //Hides the top status bar for androids.
    // SystemChrome.setEnabledSystemUIOverlays([]);

    //return the SignaturePad widget
    return ScaffoldBody(
      scaffoldBackground: Theme.of(context).primaryColor,
      body: new SignaturePad(),
      title: '',
      enableAppBar: false,
    );
  }
}
