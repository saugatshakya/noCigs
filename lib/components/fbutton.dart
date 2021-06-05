import 'package:flutter/material.dart';

class fbutton extends StatelessWidget {
  fbutton({this.function, this.icon, this.color});
  final Function function;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: function,
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ));
  }
}
