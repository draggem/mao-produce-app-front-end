import 'dart:convert';
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
  var svg;

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
                  RaisedButton(
                    onPressed: control.clear,
                    child: Text('Clear'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        svg = base64
                            .encode(
                              utf8.encode(
                                control.toSvg(
                                  color: Colors.blueGrey,
                                  size: 2.0,
                                  maxSize: 15.0,
                                  type: SignatureDrawType.shape,
                                ),
                              ),
                            )
                            .toString();
                      });
                      provider.addSign(svg);
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
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
