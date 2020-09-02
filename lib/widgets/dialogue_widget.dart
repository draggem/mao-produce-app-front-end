import 'package:flutter/material.dart';

class DialogueWidget extends StatefulWidget {
  final String title;
  final String msg;
  final String btnMsg;
  final function;
  final bgColor;
  final textColor;
  final bool isForm;
  final BuildContext ctx;

  DialogueWidget({
    this.ctx,
    this.title,
    this.msg,
    this.btnMsg,
    this.function,
    this.bgColor,
    this.textColor,
    this.isForm,
  });

  @override
  _DialogueWidgetState createState() => _DialogueWidgetState();
}

class _DialogueWidgetState extends State<DialogueWidget> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(widget.ctx);
    return AlertDialog(
      elevation: 0,
      title: _isLoading
          ? Text('')
          : Text(
              widget.title,
              style: TextStyle(
                color: widget.textColor,
              ),
            ),
      backgroundColor: _isLoading ? Colors.transparent : widget.bgColor,
      content: _isLoading
          ? Center(
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 9,
                  )),
            )
          : Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Text(
                    widget.msg,
                    style: TextStyle(color: widget.textColor),
                  ),
                  Form(
                    key: _form,
                    child: ListView(
                      children: <Widget>[TextFormField()],
                    ),
                  )
                ],
              ),
            ),
      actions: <Widget>[
        FlatButton(
            child: _isLoading
                ? Text('')
                : Text(
                    widget.btnMsg,
                    style: TextStyle(color: widget.textColor),
                  ),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await widget.function;
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop();
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop();
                scaffold.showSnackBar(
                  SnackBar(
                      content: Text(
                        'Progress Failed',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: widget.textColor),
                      ),
                      backgroundColor: Colors.red),
                );
              }
            }),
        FlatButton(
            child: _isLoading
                ? Text('')
                : Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ],
    );
  }
}
