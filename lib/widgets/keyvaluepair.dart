import 'package:flutter/material.dart';


class KeyValuePair extends StatelessWidget {
  const KeyValuePair({
    Key key,
    @required this.label,
    @required this.value,
    @required this.color,
  }) : super(key: key);

  final label;
  final value;
  final color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style:  Theme.of(context).textTheme.headline2,
        ),
        Text(
          value,
          style:  Theme.of(context).textTheme.bodyText1.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
