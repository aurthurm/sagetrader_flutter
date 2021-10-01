import 'package:flutter/material.dart';

/*
 * Custom Floating Action Button Stack
*/
class FABStack extends StatelessWidget {
  final IconData icon;
  FABStack({this.icon});
  @override
  Widget build(BuildContext context) {
    return Stack(
      // overflow: Overflow.visible,
      children: <Widget>[
        Positioned(
          bottom: 15,
          left: 15,
          child: Icon(icon, size: 20),
        ),
        Positioned(
          right: 10,
          top: 12,
          child: Icon(Icons.add, size: 15),
        ),
      ],
    );
  }
}
