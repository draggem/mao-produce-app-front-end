import 'package:flutter/material.dart';

class ScaffoldBody extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget drawer;

  ScaffoldBody({this.body, this.actions, this.title, this.drawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      drawer: drawer,
      body: WillPopScope(
          onWillPop: () async {
            if (Navigator.of(context).userGestureInProgress)
              return false;
            else
              return true;
          },
          child: body),
    );
  }
}
