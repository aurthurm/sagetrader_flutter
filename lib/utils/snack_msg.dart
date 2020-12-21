import 'package:flutter/material.dart';

messagesSnackBar(BuildContext context, String msg) {
  Scaffold.of(context).hideCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ),
  );
}