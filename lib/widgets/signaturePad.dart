import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:provider/provider.dart';

import '../providers/adding_product_order.dart';

class SignaturePad extends StatefulWidget {
  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final HandSignatureControl control = new HandSignatureControl(
    threshold: 5.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

//svg base64 code
  var encoded;
  //image
  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);
  ByteData rawImageByte;
  @override
  Widget build(BuildContext context) {
    //adding order provider
    var provider = Provider.of<AddingProductOrder>(context);
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints.expand(),
                        color: Colors.white,
                        child: HandSignaturePainterView(
                          control: control,
                          type: SignatureDrawType.shape,
                        ),
                      ),
                      CustomPaint(
                        painter: DebugSignaturePainterCP(
                          control: control,
                          cp: false,
                          cpStart: false,
                          cpEnd: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  FlatButton(
                    onPressed: control.clear,
                    child: Text('Clear', style: TextStyle(color: Colors.white)),
                  ),
                  FlatButton(
                    onPressed: () async {
                      rawImage.value = await control.toImage(
                        color: Colors.blueGrey,
                        format: ImageByteFormat.png,
                      );

                      encoded = base64
                          .encode(rawImage.value.buffer.asUint8List())
                          .toString();
                      provider.addSign(encoded);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
