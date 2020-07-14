import 'package:flutter/material.dart';

class OptionsTile extends StatelessWidget {
  final String routeName;
  final String title;
  final Color color;
  final IconData icon;

  OptionsTile(this.routeName, this.title, this.color, this.icon);

  void _selectTile(BuildContext ctx, String routeName) {
    Navigator.of(ctx).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(15),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => _selectTile(context, routeName),
          splashColor: Colors.black,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.white, size: 30),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
