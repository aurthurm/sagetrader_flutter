import 'package:flutter/material.dart';

messagesSnackBar(BuildContext context, String msg, Color color, int duration) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: Duration(seconds: duration)),
  );
}

cpiMsgSnackBar(BuildContext context, String msg, Color color, int duration) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Row(children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 2.0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 20),
          Text(msg)
        ]),
        backgroundColor: color,
        duration: Duration(seconds: duration)),
  );
}

doneMsgSnackBar(BuildContext context, String msg, Color color, int duration) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Row(children: <Widget>[
          Icon(Icons.info_outline, color: Colors.red),
          SizedBox(width: 20),
          Text(msg)
        ]),
        backgroundColor: color,
        duration: Duration(seconds: duration)),
  );
}
