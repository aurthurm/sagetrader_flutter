import 'package:flutter/material.dart';

class DropDownFormField extends StatefulWidget {
  final item, items;
  DropDownFormField({Key key, this.item, this.items}) : super(key: key);

  @override
  _DropDownFormFieldState createState() => _DropDownFormFieldState();
}

class _DropDownFormFieldState extends State<DropDownFormField> {
  List<String> items;
  String item;
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select an Instrument',
          ),
          isEmpty: item == '',
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: item,
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  item = newValue;
                  state.didChange(newValue);
                });
              },
              items: items.map((value) {
                return new DropdownMenuItem(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
