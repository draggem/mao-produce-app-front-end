import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/cupertino.dart';

// Setup AWS User Pool Id & Client Id settings here:
// const _awsUserPoolId = 'ap-southeast-2_l21ZHZvby';
// const _awsClientId = '49d8h3c53rsqlprucmdm7lh8p6';

const _awsUserPoolId = 'ap-southeast-2_vbxCBCIDH';
const _awsClientId = '7qdkjuuin2veoh7toulkqooc3h';

class Secret with ChangeNotifier {
  static final userPool = new CognitoUserPool(
    _awsUserPoolId,
    _awsClientId,
  );
}
