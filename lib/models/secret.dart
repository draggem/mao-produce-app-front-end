import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/cupertino.dart';

// Setup AWS User Pool Id & Client Id settings here:
const _awsUserPoolId = 'ap-southeast-2_ZFfP5RThP';
// const _awsClientId = '7jeh8rvdp9hl80sl9cpaqb9lvl';
// const _awsClientSecret = 'l1ip6dkdtkq8h2vjavf7st7h8oem0i4vkgbrqj58h6i6a6k5ch3';
const _awsClientId = '2arm9b8dtjpbh1daa7t9l2jobh';

class Secret with ChangeNotifier {
  static final userPool = new CognitoUserPool(
    _awsUserPoolId,
    _awsClientId,
  );
}
