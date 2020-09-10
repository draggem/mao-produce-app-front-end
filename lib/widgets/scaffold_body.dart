import 'package:flutter/material.dart';

class ScaffoldBody extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget drawer;
  final bool centerTitle;
  final double elevation;
  final Color scaffoldBackground;
  final Widget floatingActionButton;

  ScaffoldBody({
    this.body,
    this.actions,
    this.title,
    this.drawer,
    this.centerTitle = false,
    this.elevation,
    this.scaffoldBackground,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        elevation: elevation,
        centerTitle: centerTitle,
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
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
